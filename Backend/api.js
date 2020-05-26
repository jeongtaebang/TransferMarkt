var express = require('express');
let mysql = require('mysql');
const bodyParser = require('body-parser');
var config = require('./config');
let jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const { v1: uuidv1 } = require('uuid');
var cors = require('cors')


var app = express();
const saltRound = 10;
const skey = config.skey;

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

const verifyToken = (req, res, next) => {
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


// Match Player Club Id with User's Club Id
var verifyClub = (playerId, clubId, next) => global.connection.query("SELECT clubId FROM TransferMarkt.Players WHERE playerId = ?", [playerId], (error, results, fields) => {
    if (error) throw error;
    console.log(results);
    
    if (results.length === 0 || typeof results === undefined) {
        res.status(404).send("Wrong ID or Password");
    } else {
        var rows = JSON.parse(JSON.stringify(results[0]));
        
        rows.clubId == userData.user.clubId ? next() : res.status(404).send("Permission Denied.");
    }
});


// SEARCH for player:
router.get("/api/search_player/", verifyToken, (req, res, next) => {
	
	var my_query = () => { 
	
		// Get search terms
		const search_terms = req.body.search_terms;
		const term_list = search_terms.toLowerCase().split(' ');
		console.log(term_list);
		
		// Keep track of search rankings and return response to user
		var response = "";
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
			});
		});
	};

	if (typeof req.body.search_terms === undefined || req.body.search_terms.length === 0) {
		res.status(404).send("No search terms passed in query");
	} else {

		jwt.verify(req.token, skey, (err, userData) => {
    	    if (err) {res.status(404).send("Invalid JWT Token")}
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
		const search_terms = req.body.search_terms;
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
			});
		});
	};

	if (typeof req.body.search_terms === undefined || req.body.search_terms.length === 0) {
		res.status(404).send("No search terms passed in query");
	} else {

		jwt.verify(req.token, skey, (err, userData) => {
    	    if (err) {res.status(404).send("Invalid JWT Token")}
    	    else {
    	        console.log(userData);
    	        my_query();
    	    }
    	});
	}
});



// GET players
router.get("/api/players/", 
verifyToken, 
(req, res, next) => {

    var FirstName = ("FirstName" in req.query)? req.query.FirstName : "";
    var LastName = ("LastName" in req.query)? req.query.LastName : "";

    var my_query = () => global.connection.query('SELECT * FROM TransferMarkt_sp20.Players WHERE FirstName LIKE ? AND LastName LIKE ?', [`%${FirstName}%`, `%${LastName}%`], (error, results, field) => {
        if (error) throw error
        // console.log("players got: "+ JSON.stringify(results));
        res.send(JSON.stringify({ "status": 200, "error": null, "response": results }));
    });

    // carry on with queries if token is verified
    jwt.verify(req.token, skey, (err, userData) => {
        if (err) {res.status(404).send("Invalid JWT Token")}
        else {
            console.log(userData);
            my_query();
        }
    });
});

router.get("/api/clubs/", verifyToken, (req, res, next) => {
    var ClubName = ("ClubName" in req.query)? req.query.ClubName : "";
    var ClubId = ("ClubID" in req.query)? req.query.ClubID : "";
    
    var my_query = () => global.connection.query('SELECT * FROM TransferMarkt_sp20.Clubs WHERE ClubName LIKE ? AND ClubID LIKE ?', [`%${ClubName}%`, `%${ClubId}%`], (error, results, field) => {
        if (error) throw error
        res.send(JSON.stringify({ "status": 200, "error": null, "response": results }));
    });

    // carry on with queries if token is verified
    jwt.verify(req.token, skey, (err, userData) => {
		if (err) res.status(404).send("Invalid JWT Token");
        else {
			console.log(userData);
            my_query();
		}
	});
});

router.get("/api/trade/:id", verifyToken, (req, res, next) => {
    var my_query = () => global.connection.query('SELECT * FROM TransferMarkt_sp20.Requests WHERE PackageID = ?', [req.query.id], (error, results, field) => {
       if (error) throw error;
       else res.send(JSON.stringify({ "status": 200, "error": null, "response": results }));
    });

    // carry on with queries if token is verified
    jwt.verify(req.token, skey, (err, userData) => {
        if (err) res.status(404).send("Invalid JWT Token");
        else {
            // console.log(userData);
            my_query();
        }
    });
});

router.get("/api/trade/", verifyToken, (req, res, next) => {
    // fetch all packages addressed to the user's clubID that is not rejected and requires signatures
    var my_query = (userData) => global.connection.query('SELECT p.PackageId, p.Date FROM TransferMarkt_sp20.Packages p, TransferMarkt_sp20.Signatures s WHERE p.PackageId = s.PackageId AND p.Status <> 0 AND s.clubID = ? AND s.Status = ?', [userData.clubId, null], (error, results, field) => {
       if (error) throw error;
       else res.send(JSON.stringify({ "status": 200, "error": null, "response": results }));
    });

    // carry on with queries if token is verified
    jwt.verify(req.token, skey, (err, userData) => {
        if (err) res.status(404).send("Invalid JWT Token");
        else {
            // console.log("userData in get trade: "+ JSON.stringify(userData));
            my_query(userData);
        }
    });
});

// PUT
// Update Player Info
router.put("/api/players/:id", verifyToken, (req, res) => {
    var attrib = req.body.attrib;
    var params = [req.body.value, req.body.club];
    
    var query_str = `UPDATE TransferMarkt_sp20.players SET %${req.body.attrib}% = ? WHERE playerId = ?`

    var my_query = () => global.connection.query(query_str, [req.params.id], (error, results, field) => {
        if (error) throw error;
        else res.send(JSON.stringify({ "status": 200, "error": null, "response": results }));
    });
    // only allow if player belongs to the manager's club
    jwt.verify(req.token, skey, (err, userData) => {
        if (err) { res.status(404).send("Invalid JWT Token") }
        else verifyClub(req.params.id, userData.clubId, my_query);
    });
});

// Sign Trade Package
router.put("/api/sign/:id", verifyToken, (req, res) => {
    // insert to transfer table if package is approved
    var insert_to_transfer = () => global.connection.query('INSERT INTO TransferMarkt.Transfers VALUES(?, CURRENT_TIMESTAMP)', [req.params.id], (error, results, field) => {
        if (error) throw error;
        else console.log(`Package %${req.params.id}% approved and added to transfer table.`); 
    });

    // status = -1 (pending), 0 (rejected), 1(accepted)
    // when sum(status) == count(status), the trade package has been accepted by all clubs, hence approved.
    var check_complete = (next) => global.connection.query('SELECT COUNT(Status) = SUM(Status) AS Approved FROM TransferMarkt.Signatures WHERE PackageId = ?', [req.params.id], (error, results, field) => {
        if (error) throw error;
        else 
            if (results.length === 0 || typeof results === undefined)
                res.status(404).send("Package ID NOT FOUND.");
            else {
                var rows = JSON.parse(JSON.stringify(results[0]));
                if (rows.Approved) next();
            }
    });

    // update package status
    var update_package = () => global.connection.query('UPDATE TransferMarkt.Package SET Status = Status * ? WHERE PackageId = ?', [req.body.status, req.params.id], (error, results, field) => {
        if (error) throw error;
        else console.log(`Package %${req.body.status}% Status Updated.`)
    });
    
    // update signature entry
    var update_signature = (userData) => global.connection.query('UPDATE TransferMarkt.Signatures SET Status = ? WHERE PackageId = ? AND ClubId = ?', [req.body.status, req.params.id, userData.clubId], (error, results, field) => {
        if (error) throw error;
        else res.send(JSON.stringify({"status" : 200, "error" : null, "response" : results}));
        check_complete(insert_to_transfer);
    });

    jwt.verify(req.token, skey, (err, userData) => {
        if (err) res.status(404).send("Invalid JWT Token");
        else
        {
            // update_package and update_signature don't need to be run synchronously
            update_package();
            update_signature(userData);
        }
    });

});

// POST
// New Player
router.post("/api/players/", verifyToken, (req, res) => {
    var my_query = () => global.connection.query('INSERT INTO TransferMarkt.Players VALUES(?, ?, ?, ?, ?, ?)', [null, req.body.FirstName, req.body.LastName, req.body.Age, req.body.ClubId, req.body.Salary], (error, results, field) => {
        if (error) throw error;
        else res.send(JSON.stringify({"status" : 200, "error" : null, "response" : results}));
    });

    jwt.verify(req.token, skey, (err, userData) => {
        if (err) res.status(404).send("Invalid JWT Token");
        else {
            console.log(userData);
            // only allow clubs to register new player for their team only
            if (userData.clubId != req.body.clubId)
                res.status(404).send("Permission Denied.");
            else
                my_query();
        }
    });
});

// Make Trade Package Request
router.post("/api/trade/", verifyToken, (req, res) => {
    
    var packageId = uuidv1();

    var create_requests = () => req.body.requests.forEach((request)=>
        global.connection.query('INSERT INTO TransferMarkt.Requests VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)', [null, req.body.packageId, req.body.from, req.body.to, req.body.playerId, req.body.type, req.body.transfer_fee, req.body.salary, req.body.date], (error, results, field) => {
            if (error) throw error;
            res.send(JSON.stringify({"status" : 200, "error" : null, "response" : results}));
        }));

    // trade package status defaulted to be accepted for easier backend processing (0 = rejected, 1 = accepted)
    var create_trade = () => global.connection.query('INSERT INTO TransferMarkt.TradePackage VALUES(?, ?)', [packageId, 1], (error, results, field) => {
        if (error) throw error;
        else
            create_requests();
    });

    jwt.verify(req.token, skey, (err, userData) => {
        if (err) res.status(404).send("Invalid JWT Token");
        else
            create_trade();
    });

});

// DELETE
// Delete player info
router.delete("/api/players/:id", verifyToken, (req, res) => {
    // callback to delete if admin
    admin_query = () => global.connection.query('DELETE FROM TransferMarkt_sp20.Players WHERE playerId = ?', [req.params.id], (error, results, field) => {
        if (error) throw error;
        res.send(JSON.stringify({"status" : 200, "error" : null, "response" : results}));
    });
    
    jwt.verify(req.token, skey, (err, userData) => {
        if (err) { res.status(404).send("Invalid JWT Token") }
        else {
            console.log(userData);
            // allow only if the player belongs to the admin's club
            verifyClub(req.params.id, userData.clubId, admin_query);
        }
    });
});


// LOGIN
router.post("/api/login/", (req, res) => {

    var user = {
        username: req.body.login_username, 
        pw: req.body.login_password,
        is_admin: false
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

                    jwt.sign({ user }, skey, { expiresIn: '1h' }, (err, token) => {
                        if (err) throw err;
                        res.send(JSON.stringify({ "status": 200, "error": null, 
                        "response": token, "clubId": rows.ClubID }));
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
