var express = require('express');
let mysql = require('mysql');
const bodyParser = require('body-parser');

// Select config to use:
// var config = require('./config');
var config = require('./config-aws');
let jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const { v1: uuidv1 } = require('uuid');
var cors = require('cors')


// Debug Mode?
var debug = false;

var app = express();
const saltRound = 10;
const skey = config.skey;

// const userData = {
//     privilege : 1,
//     clubId : 1,
// };

// Connect to database
app.use((req, res, next) => {   
    global.connection = mysql.createConnection({
        host : config.database.host,
        user : config.database.user,
        password : config.database.password,
        database : config.database.schema
    });
    connection.connect();
    next();
});

app.use(bodyParser.urlencoded({extended: true}));
app.use(bodyParser.json());

app.use(cors())

// initialize router
var router = express.Router();

// log
router.use((req, res, next) => {
    console.log("/" + req.method);
    next();
});

// configure router REST API
router.get("/", (_, res) => {
    res.send("Transfer Market");
});

// Check presence of JWT Token (in HTTP request)
const verifyToken = (req, res, next) => {
    if (debug)
    {
        next();
        return;
    }
    const tokHeader = req.headers['authorization'];
    if (typeof tokHeader !== undefined) {
        const bearer = tokHeader.split(' ');
        const token = bearer[1];
        req.token = token;
     next();
    } else {
        res.status(404).send("Permission denied");
    }
}

var getDate = () => {
    return new Date().toISOString().slice(0, 19).replace('T', ' ');
};

// Create a player object
var createPlayer = (body) => {
    return {
        PlayerID : null,
        FirstName : body.FirstName,
        LastName : body.LastName,
        Age : body.Age,
        Salary : body.Salary,
        ClubID : body.ClubID
    };
};

var createRequest = (body, packageID) => {
    return {
        RequestID : null,
        From : body.From,
        To : body.To,
        PlayerID : body.PlayerID,
        TransferFee : body.TransferFee,
        NewSalary : body.NewSalary,
        DateOfRequest : getDate(),
        PackageID : packageID
    };
};

var createPackage = (packageID) => {
    return {
        PackageID : packageID,
        Status : 1,
        Date : getDate()
    };
};

var createSignature = (clubID, packageID) => {
    return {
        PackageID : packageID,
        ClubID : clubID,
        Status : -1
    };
};


// Match Player Club Id with User's Club Id
var verifyClub = (playerId, clubId, next, res) => global.connection.query("SELECT clubId FROM TransferMarkt_sp20.Players WHERE playerId = ?", [playerId], (error, results, fields) => {
    if (error) throw error;
    console.log(results);
    
    if (results.length === 0 || typeof results === undefined) {
        res.status(404).send("Wrong ID or Password");
    } else {
        var rows = JSON.parse(JSON.stringify(results[0]));
        
        rows.clubId == clubId ? next() : res.status(404).send("Permission Denied."); // deploy ver
        // rows.clubId == userData.user.clubId ? next() : console.log("Permission Denied."); // debug ver
    }
});


// SEARCH for player:
router.get("/api/search_player/", verifyToken, (req, res, next) => {
    
    console.log("in search; search_terms: "+req.query.search_terms);

	var my_query = () => { 
	
		// Get search terms
		const search_terms = req.query.search_terms;
		const term_list = search_terms.toLowerCase().split(' ');
		console.log(term_list);
		
		// Keep track of search rankings
		var search_rankings = {};
		
		term_list.forEach((value, index, array) => {

			const term = '%' + value + '%'; // surround with wildcards to find partial matches
			global.connection.query("SELECT * FROM TransferMarkt_sp20.Players WHERE LOWER(FirstName) LIKE ? OR LOWER(LastName) LIKE ?",
				[term, term] , (error, results, fields) => {

				if (error) throw error;
				if (results.length) {
					// Add returned players to search_rankings dictionary
					results.forEach((player, index1, array1) => {

						const player_string = JSON.stringify(player)
						if (!(player_string in search_rankings)) search_rankings[player_string] = 1;
						else search_rankings[player_string] += 1;

						// When results are finished
						if (index === array.length - 1 && index1 === array1.length - 1) {

							// Create 2D array of dictionary entries:
							var search_results = Object.keys(search_rankings).map(function(key) {
								return [key, search_rankings[key]];
							});
							
							// Rank the clubs returned by number of queries returned
							search_results.sort(function(first, second) {
								return second[1] - first[1];
							});

							// Return only player information (drop # of queries returned)
							var results_list = Object.values(search_results).map(function(value) {
								return value[0];
							});
							
							// Top 5 search results:
							console.log(search_results.slice(0,5)); // uncomment for debugging
							const top_hits = results_list.slice(0,5);
							const response = '{"status": 200,"error": null,"response":[' + top_hits + ']}';
        					res.send(response);
						}
					});
                }
                else if (index == array.length - 1)
                {
                    res.send('{"status": 200, "error": null, "response":[]}');
                }
			});
		});
	};

	if (!req.query.search_terms|| req.query.search_terms.length === 0) {
		res.status(404).send("No search terms passed in query");
	} else {

		jwt.verify(req.token, skey, (err, userData) => {
    	    if (err && !debug) {res.status(404).send("Invalid JWT Token")}
    	    else {
    	        console.log(userData);
    	        my_query();
    	    }
    	});
	}
});


// SEARCH for club:
router.get("/api/search_club/", verifyToken, (req, res, next) => {
	
	var my_query = () => { 
	
		// Get search terms
		const search_terms = req.query.search_terms;
		const term_list = search_terms.toLowerCase().split(' ');
        console.log(term_list);
		
		// Keep track of search rankings and return response to user
		var response = "";
		var search_rankings = {};
		
		term_list.forEach((value, index, array) => {

			const term = '%' + value + '%'; // surround with wildcards to find partial matches
			global.connection.query("SELECT * FROM TransferMarkt_sp20.Clubs WHERE LOWER(ClubName) LIKE ?",
				[term] , (error, results, fields) => {

				if (error) throw error;
				if (results.length) {
					// Add returned clubs to search_rankings dictionary
					results.forEach((club, index1, array1) => {

						const club_string = JSON.stringify(club)
						if (!(club_string in search_rankings)) search_rankings[club_string] = 1;
						else search_rankings[club_string] += 1;

						// When results are finished
						if (index === array.length - 1 && index1 === array1.length - 1) {

							// Create 2D array of dictionary entries:
							var search_results = Object.keys(search_rankings).map(function(key) {
								return [key, search_rankings[key]];
							});
							
							// Rank the clubs returned by number of queries returned
							search_results.sort(function(first, second) {
								return second[1] - first[1];
							});

							// Return only player information (drop # of queries returned)
							var results_list = Object.values(search_results).map(function(value) {
								return value[0];
							});
							
							// Top 5 search results:
							console.log(search_results.slice(0,5)); // uncomment for debugging
							const top_hits = results_list.slice(0,5);
							const response = '{"status": 200,"error": null,"response":[' + top_hits + ']}';
        					res.send(response);
                        }
					});
                }
                else if (index == array.length - 1)
                {
                    res.send('{"status": 200, "error": null, "response":[]}');
                }
			});
		});
	};

	if (!req.query.search_terms || req.query.search_terms.length === 0) {
		res.status(404).send("No search terms passed in query");
	} else {

		jwt.verify(req.token, skey, (err, userData) => {
    	    if (err && !debug) {res.status(404).send("Invalid JWT Token")}
    	    else {
    	        console.log(userData);
    	        my_query();
    	    }
    	});
	}
});


// GET single player:
router.get("/api/players/:id", verifyToken, (req, res, next) => {
    var my_query = () => global.connection.query('SELECT * FROM TransferMarkt_sp20.Players WHERE PlayerID = ?', 
		[req.params.id], (error, results, field) => {
        if (error) throw error
        res.send(JSON.stringify({ "status": 200, "error": null, "response": results }));
    });

    // carry on with queries if token is verified
    jwt.verify(req.token, skey, (err, userData) => {
        if (err && !debug) {res.status(404).send("Invalid JWT Token")}
        else {
            console.log(userData);
            my_query();
        }
    });
});


// GET all players (if no ClubID passed) or all players within a single club (if clubID passed)
router.get("/api/players/", verifyToken, (req, res, next) => {

    var my_query = () => {

		var query_str = 'SELECT * FROM TransferMarkt_sp20.Players'
		if (req.query.club_id !== undefined) query_str = 'SELECT * FROM TransferMarkt_sp20.Players WHERE ClubID = ?'

		global.connection.query(query_str, [req.query.club_id],
			(error, results, field) => {
        	if (error) throw error
        	res.send(JSON.stringify({ "status": 200, "error": null, "response": results }));
    	});
	}

    // carry on with queries if token is verified
    jwt.verify(req.token, skey, (err, userData) => {
        if (err && !debug) {res.status(404).send("Invalid JWT Token")}
        else {
            console.log(userData);
            my_query();
        }
    });
});


// GET Single Club:
router.get("/api/clubs/:id", verifyToken, (req, res, next) => {
    console.log("getting single club, req params id: "+req.params.id)
    var my_query = () => global.connection.query('SELECT * FROM TransferMarkt_sp20.Clubs WHERE ClubID = ?', 
		[req.params.id], (error, results, field) => {
        if (error) throw error
        // console.log("players got: "+ JSON.stringify(results));
        res.send(JSON.stringify({ "status": 200, "error": null, "response": results }));
    });

    // carry on with queries if token is verified
    jwt.verify(req.token, skey, (err, userData) => {
        if (err && !debug) {res.status(404).send("Invalid JWT Token")}
        else {
            console.log(userData);
            my_query();
        }
    });
});


// GET All Clubs
router.get("/api/clubs/", verifyToken, (req, res, next) => {

    var my_query = () => global.connection.query('SELECT * FROM TransferMarkt_sp20.Clubs', 
		(error, results, field) => {
        if (error) throw error
        res.send(JSON.stringify({ "status": 200, "error": null, "response": results }));
    });

    // carry on with queries if token is verified
    jwt.verify(req.token, skey, (err, userData) => {
		if (err && !debug) res.status(404).send("Invalid JWT Token");
        else {
			console.log(userData);
            my_query();
		}
	});
});


// GET Trade by ID:
router.get("/api/trade/:id", verifyToken, (req, res, next) => {
    var my_query = () => global.connection.query('SELECT * FROM TransferMarkt_sp20.Requests WHERE PackageID = ?', 
    [req.params.id], (error, results, field) => {
       if (error) throw error;
       else res.send(JSON.stringify({ "status": 200, "error": null, "response": results }));
    });

    // carry on with queries if token is verified
    jwt.verify(req.token, skey, (err, userData) => {
        if (err && !debug) res.status(404).send("Invalid JWT Token");
        else {
            console.log(userData);
            my_query();
        }
    });
});


// Fetch all packages addressed to the user's clubID that is not rejected and requires signatures
router.get("/api/trade/", verifyToken, (req, res, next) => {
    var my_query = (userData) => global.connection.query('SELECT p.PackageID, p.Status, p.Date FROM TransferMarkt_sp20.Packages p, TransferMarkt_sp20.Signatures s WHERE p.PackageId = s.PackageId AND p.Status = 1 AND s.ClubID = ? AND s.Status = ?', 
    [userData.user.clubId, -1], (error, results, field) => {
       if (error) throw error;
       else res.send(JSON.stringify({ "status": 200, "error": null, "response": results }));
    });

    // carry on with queries if token is verified
    jwt.verify(req.token, skey, (err, userData) => {
        if (err && !debug) res.status(404).send("Invalid JWT Token");
        else {
            console.log(userData);
            my_query(userData);
        }
    });
});

// Fetch past 10 tranfers clubID
router.get("/api/transfers/:id", verifyToken, (req, res, next) => {
    var my_query = () => global.connection.query('SELECT t.PackageID, t.Date_Signed FROM TransferMarkt_sp20.Transfers t, TransferMarkt_sp20.Signatures s WHERE t.PackageID = s.PackageID AND s.ClubID = ? ORDER BY t.Date_Signed DESC LIMIT 10', 
    [req.params.id], (error, results, field) => {
       if (error) throw error;
       else res.send(JSON.stringify({ "status": 200, "error": null, "response": results }));
    });

    // carry on with queries if token is verified
    jwt.verify(req.token, skey, (err, userData) => {
        if (err && !debug) res.status(404).send("Invalid JWT Token");
        else {
            console.log(userData);
            my_query();
        }
    });
});

// Fetch past 10 tranfers
router.get("/api/transfers/", verifyToken, (req, res, next) => {
    var my_query = () => global.connection.query('SELECT * FROM TransferMarkt_sp20.Transfers ORDER BY Date_Signed DESC LIMIT 10', 
    [], (error, results, field) => {
       if (error) throw error;
       else res.send(JSON.stringify({ "status": 200, "error": null, "response": results }));
    });

    // carry on with queries if token is verified
    jwt.verify(req.token, skey, (err, userData) => {
        if (err && !debug) res.status(404).send("Invalid JWT Token");
        else {
            console.log(userData);
            my_query();
        }
    });
});

// PUT
// Update Player Info
router.put("/api/players/:id", verifyToken, (req, res) => {
    
    var query_str = `UPDATE TransferMarkt_sp20.Players SET ? WHERE playerId = ?`
    console.log(req.body);
    var my_query = () => global.connection.query(query_str, [req.body, req.params.id], (error, results, field) => {
        if (error) throw error;
        else res.send(JSON.stringify({ "status": 200, "error": null, "response": results }));
    });
    // only allow if player belongs to the manager's club
    jwt.verify(req.token, skey, (err, userData) => {
        if (err && !debug) res.status(404).send("Invalid JWT Token");
        else 
            verifyClub(req.params.id, userData.user.clubId, my_query, res);
    });
});

// Sign Trade Package
router.put("/api/sign/:id", verifyToken, (req, res) => {
    // insert to transfer table if package is approved
    var response = [];

    var insert_to_transfer = () => global.connection.query('INSERT INTO TransferMarkt_sp20.Transfers VALUES(?, CURRENT_TIMESTAMP)', [req.params.id], (error, results, field) => {
        if (error) throw error;
        else
        {
            response.push(results);
            res.send(JSON.stringify({"status" : 200, "error" : null, "response" : response}));
        }
    });

    // status = -1 (pending), 0 (rejected), 1(accepted)
    // when sum(status) == count(status), the trade package has been accepted by all clubs, hence approved.
    var check_complete = (next) => global.connection.query('SELECT COUNT(Status) = SUM(Status) AS Approved FROM TransferMarkt_sp20.Signatures WHERE PackageId = ?', [req.params.id], (error, results, field) => {
        if (error) throw error;
        else 
            if (results.length === 0 || typeof results === undefined)
                res.status(404).send("Package ID NOT FOUND.");
            else {
                response.push(results[0]);
                var rows = JSON.parse(JSON.stringify(results[0]));
                if (rows.Approved) next();
                else res.send(JSON.stringify({"status" : 200, "error" : null, "response" : response}));
            }
    });

    // update package status
    var update_package = () => global.connection.query('UPDATE TransferMarkt_sp20.Packages SET Status = Status * ? WHERE PackageId = ?', [req.body.status, req.params.id], (error, results, field) => {
        if (error) throw error;
        else
        {
            console.log(`Package %${req.body.status}% Status Updated.`);
            response.push(results);
        }
    });
    
    // update signature entry
    var update_signature = (u) => global.connection.query('UPDATE TransferMarkt_sp20.Signatures SET Status = ? WHERE PackageId = ? AND ClubId = ?', [req.body.status, req.params.id, u.clubId], (error, results, field) => {
        if (error) throw error;
        else 
            response.push(results);
        check_complete(insert_to_transfer);
    });

    jwt.verify(req.token, skey, (err, userData) => {
        if (err && !debug) res.status(404).send("Invalid JWT Token");
        else
        {
            // update_package and update_signature don't need to be run synchronously
            update_package();
            update_signature(userData.user);
        }
    });

});

// POST
// New Player
router.post("/api/players/", verifyToken, (req, res) => {
    var player = createPlayer(req.body);
    var response = [];

    var new_player = () => global.connection.query('INSERT INTO TransferMarkt_sp20.Players VALUES(?)', [Object.values(player)], (error, results, field) => {
        if (error) throw error;
        else
        {
            response.push(results);            
            update_position(req.body.Positions, 0, results.insertId);
        }
    });
    
    var update_position = (positions, index, playerId) => {
        if (index == positions.length)
            res.send(JSON.stringify({"status" : 200, "error" : null, "response" : response}));
        else
            global.connection.query('INSERT INTO TransferMarkt_sp20.PlayerPositions VALUES(?)', [[playerId, positions[index]]], (error, results, field) => {
                if (error) throw error;
                else 
                {
                    response.push(results);
                    update_position(positions, index + 1, playerId);
                }
            });
    };
    
    console.log(req.body);

    jwt.verify(req.token, skey, (err, userData) => {
        if (err && !debug) res.status(404).send("Invalid JWT Token");
        else {
            // only allow clubs to register new player for their team only
            if (userData.user.clubId != req.body.ClubID)
                res.status(404).send("Permission Denied.");
            else
                new_player();
        }
    });
});

// Make Trade Package Request
router.post("/api/trade/", verifyToken, (req, res) => {
    
    var packageID = uuidv1();

    var teams = new Set();

    var create_requests = () => req.body.requests.forEach((request) =>
    {
        global.connection.query('INSERT INTO TransferMarkt_sp20.Requests VALUES(?)', [Object.values(createRequest(request, packageID))], (error, results, field) => {
            if (error) throw error;
            else if (!teams.has(request.To))
            {
                teams.add(request.To);
                global.connection.query('INSERT INTO TransferMarkt_sp20.Signatures VALUES(?)', [Object.values(createSignature(request.To, packageID))], (error, results, field) => {
                    if (error) throw error;
                });
            }
            else if (!teams.has(request.From))
            {
                teams.add(request.From);
                global.connection.query('INSERT INTO TransferMarkt_sp20.Signatures VALUES(?)', [Object.values(createSignature(request.From, packageID))], (error, results, field) => {
                    if (error) throw error;
                });
            }
        });
    });

    // trade package status defaulted to be accepted for easier backend processing (0 = rejected, 1 = accepted)
    var create_trade = () => global.connection.query('INSERT INTO TransferMarkt_sp20.Packages VALUES(?)', [Object.values(createPackage(packageID))], (error, results, field) => {
        if (error) throw error;
        else
            create_requests();
    });

    jwt.verify(req.token, skey, (err, userData) => {
        if (err && !debug) res.status(404).send("Invalid JWT Token");
        else
        {
            create_trade();
            res.send(JSON.stringify({"status" : 200, "error" : null, "response" : packageID}));
        }    
    });

});

// DELETE
// Delete player info
router.delete("/api/players/:id", verifyToken, (req, res) => {
    // callback to delete if admin
    admin_query = () => global.connection.query('DELETE FROM TransferMarkt_sp20.Players WHERE playerId = ?', [Number(req.params.id)], (error, results, field) => {
        if (error) throw error;
        res.send(JSON.stringify({"status" : 200, "error" : null, "response" : results}));
    });
    
    jwt.verify(req.token, skey, (err, userData) => {
        if (err && !debug) { res.status(404).send("Invalid JWT Token") }
        else {
            console.log(userData);
            // allow only if the player belongs to the admin's club
            verifyClub(req.params.id, userData.user.clubId, admin_query, res);
        }
    });
});


// LOGIN
router.post("/api/login/", (req, res) => {

    var user = {
        username: req.body.login_username, 
        pw: req.body.login_password,
        privilege: 0,
        clubId : 0
    }

    global.connection.query("SELECT SaltedPassword, ClubID, AdminPrivilege FROM TransferMarkt_sp20.Managers WHERE Username = ?", [user.username], (error, results, fields) => {
        if (error) throw error;
        console.log(results);

        if (results.length === 0 || typeof results === undefined) {
            res.status(404).send("Wrong ID or Password");
        } else {
            var rows = JSON.parse(JSON.stringify(results[0]));

            // for testing node bcrypt output
            // bcrypt.hash(user.pw, 12, function(err, hash) {
			// 	console.log(hash);
            // });

            bcrypt.compare(user.pw, rows.SaltedPassword, (error, result) => {
                if (error) throw error;
                if (result) {
                    user.privilege = rows.AdminPrivilege;
                    user.clubId = rows.ClubID;

                    jwt.sign({ user }, skey, {}, (err, token) => {
                        if (err && !debug) throw err;
                        res.send(JSON.stringify({ "status": 200, "error": null, 
                        "response": token, "clubId": rows.ClubID,
                    "username": req.body.login_username }));
                    });
                } else {
                    res.status(404).send("Wrong ID or Password");
                }
            });
        }
    });
});

app.use(express.static(__dirname + '/'));
app.use("/", router);
app.set('port', config.port || 3000);

app.listen(app.get( 'port'), () => {
    console.log('TransferMarkt API Server running.');

});
