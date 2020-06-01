var express = require('express');
let mysql = require('mysql');
const bodyParser = require('body-parser');

// Select config to use:
// var config = require('./config');
var config = require('./config-aws');
let jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const { v1: uuidv1 } = require('uuid');
var cors = require('cors');


// Debug Mode?
var debug = false;

var app = express();
const saltRound = 10;
const skey = config.skey;

const player_attribs = ["FirstName", "LastName", "Age", "Salary", "ClubID"];
const request_attribs = ["From", "To", "PlayerID", "TransferFee", "NewSalary"];

global.connection = mysql.createConnection({
    host : config.database.host,
    user : config.database.user,
    password : config.database.password,
    database : config.database.schema
});

connection.connect();

// Connect to database
app.use((req, res, next) => {   
    console.log(global.connection.state);
    if (global.connection.state === `disconnected`)
        global.connection.connect();
    next();
});

app.use(bodyParser.urlencoded({extended: true}));
app.use(bodyParser.json());

app.use(cors());

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
    if (typeof tokHeader !== 'undefined') {
        const bearer = tokHeader.split(' ');
        const token = bearer[1];
        req.token = token;
		next();
    } else {
        res.status(404).send("Permission denied");
    }
};

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


// returns true if successful
var execute_trade = (packageID, success) => {
	
	
	var get_league_info = (result) => global.connection.query("SELECT SalaryCap FROM TransferMarkt_sp20.Leagues WHERE LeagueID = 1",
	(error, results, fields) => {
        if (error){
            console.log(error);
            return;
        }
		else result(results[0].SalaryCap);
	});
	

	// Updates players involved in a trade to reflect new club and salary. Returns all clubs involved in the trade
	// Expects to be called from within a transaction.
	updates_players = (result) => {

        console.log(packageID);

		global.connection.query("SELECT `PlayerID`, `To`, `From`, `NewSalary` FROM TransferMarkt_sp20.Requests WHERE PackageID = ?",
		[packageID], (error, results, fields) => {

            if (error)
            {
                console.log(error);
                return;
            }
			clubs_involved = new Set();
			results.forEach((request, index, array) => {

				// Add teams that need to be checked
				clubs_involved.add(request.To); // won't add duplicates by default
				clubs_involved.add(request.From);

				global.connection.query("UPDATE TransferMarkt_sp20.Players SET ClubID = ?, Salary = ? WHERE PlayerID = ?",
				[request.To, request.NewSalary, request.PlayerID] , (error, results, fields) => {
					if (error) {
						global.connection.rollback(() => {
                            console.log(error);
                        });
                        return;
					}
					else if (index == array.length - 1) {
						result(clubs_involved);
                    }
				});
			});
		});
	};
    
    // Expects to be called from within a transaction.
	// Checks that all clubs are below the salary cap. Returns true if so, false if not.
	var check_constraints = (clubs_involved, index, salary_cap, passed) => {

        let clubs_array = Array.from(clubs_involved);
        console.log("check_constraint", index);
        global.connection.query("SELECT SUM(Salary) AS TeamSalary FROM Players WHERE ClubID = ? LIMIT 1", 
        [clubs_array[index]], (error, results, fields) => {
            if (error) {
                console.log(`Package Rejected: ${String(error)}`);
                passed(false);
                return;
            }
            else if (results[0].TeamSalary > salary_cap) {
                console.log(`Package Rejected: Club ${clubs_array[index]}'s salary, ${results[0].TeamSalary}, is greater than salary cap ${salary_cap}`);
                passed(false);
                return;
            }
            else if (index >= clubs_array.length - 1) {
                console.log(`Package Accepted: All involved clubs meet salary cap constraint`);
                passed(true);
                return;
            }
            else
            {
                check_constraints(clubs_involved, index + 1, salary_cap, passed);
            }
		});
	};

	// Get Salary Cap
	get_league_info((salary_cap) => {
		// Begin transaction
		global.connection.beginTransaction((error) => {
            if (error)
            {
                console.log(error);
                return;
            }

			// Update player clubs and salaries affected by trade
			updates_players(clubs_involved => {
				
				// Ensure that no clubs are over the salary cap
				check_constraints(clubs_involved, 0, salary_cap, passed => {

					if (!passed) {
						connection.rollback(() => {
							// Return that trade package has failed:
                            success(false);
						});
					}
					else {

						console.log("Made it to commit stage");

						/* End transaction */			
						global.connection.commit((err) => {
				        	if (err) { 
				        	  connection.rollback(() => {
				        	    throw err;
				        	  });
				        	}
				    		console.log('Transaction Complete. Trade Executed.');
							success(true);
					    });
					}
				});
			});
		});
	});
};


// Match Player Club Id with User's Club Id
var verifyClub = (playerId, clubId, next, param, res) => global.connection.query("SELECT clubId FROM TransferMarkt_sp20.Players WHERE playerId = ?", [playerId], (error, results, fields) => {
    if (error)
    {  
        res.status(404).send(error);
        return;
    }
    console.log(results);
    
    if (results.length === 0 || typeof results === undefined) {
        res.status(404).send(`No Player Found with ${playerId}.`);
    } else {
        var rows = JSON.parse(JSON.stringify(results[0]));
        rows.clubId == clubId ? (param ? next(param) : next()) : (!res.headersSent? res.status(404).send("Permission Denied: Player's Club ID and your Club ID do not match.") : console.log("Permission Denied: Player's Club ID and your Club ID do not match.")); // deploy ver
        // rows.clubId == userData.user.clubId ? next() : console.log("Permission Denied."); // debug ver
    }
});

var checkClubValidity = (clubID, next) => global.connection.query("SELECT SUM(p.Salary) AS TotalSalary, l.SalaryCap As SalaryCap FROM TransferMarkt_sp20.Players p, TransferMarkt_sp20.Leagues l WHERE p.ClubID = ? LIMIT 1", [clubID], (error, results, fields) => {
    if (error) 
    {
        res.status(404).send(error);
        return;
    }
    console.log(results);
    console.log(clubID);
    if (results.length === 0 || typeof results === undefined) {
        res.status(404).send(`No Club Found with ${ClubId}.`);
    } else {
        var rows = JSON.parse(JSON.stringify(results[0]));
        next(rows.SalaryCap > rows.TotalSalary);
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

                if (error) 
                {
                    res.status(404).send(error);
                    return;
                }
				if (results.length) {
					// Add returned players to search_rankings dictionary
					results.forEach((player, index1, array1) => {

						const player_string = JSON.stringify(player);
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
    	    if (err && !debug) res.status(404).send("Invalid JWT Token");
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

                if (error)
                {
                    res.status(404).send(error);
                    return;
                }
				if (results.length) {
					// Add returned clubs to search_rankings dictionary
					results.forEach((club, index1, array1) => {

						const club_string = JSON.stringify(club);
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
    	    if (err && !debug) {res.status(404).send("Invalid JWT Token");}
    	    else {
    	        console.log(userData);
    	        my_query();
    	    }
    	});
	}
});


// GET single player:
router.get("/api/players/:id", verifyToken, (req, res, next) => {
    // check if ID is int
    if (isNaN(req.params.id))
    {
        res.status(404).send("Player ID needs to be an INT.");
        return;
    }

    var my_query = () => global.connection.query('SELECT * FROM TransferMarkt_sp20.Players WHERE PlayerID = ?', 
		[req.params.id], (error, results, field) => {
        if (error) 
        {
            res.status(404).send(error);
            return;
        }
        res.send(JSON.stringify({ "status": 200, "error": null, "response": results }));
    });

    // carry on with queries if token is verified
    jwt.verify(req.token, skey, (err, userData) => {
        if (err && !debug) {res.status(404).send("Invalid JWT Token");}
        else {
            console.log(userData);
            my_query();
        }
    });
});


// GET all players (if no ClubID passed) or all players within a single club (if clubID passed)
router.get("/api/players/", verifyToken, (req, res, next) => {

    var my_query = () => {

		var query_str = 'SELECT * FROM TransferMarkt_sp20.Players';
		if (req.query.club_id !== undefined) query_str = 'SELECT * FROM TransferMarkt_sp20.Players WHERE ClubID = ?';

		global.connection.query(query_str, [req.query.club_id],
			(error, results, field) => {
            if (error)
            {
                res.status(404).send(error);
                return;
            }
        	res.send(JSON.stringify({ "status": 200, "error": null, "response": results }));
    	});
	};

    // carry on with queries if token is verified
    jwt.verify(req.token, skey, (err, userData) => {
        if (err && !debug) {res.status(404).send("Invalid JWT Token");}
        else {
            console.log(userData);
            my_query();
        }
    });
});

// Get player position
router.get("/api/player_positions/:id", verifyToken, (req, res, next) => {
    // check if ID is int
    if (isNaN(req.params.id))
    {
        res.status(404).send("Player ID needs to be an INT.");
        return;
    }

    var my_query = () => global.connection.query('SELECT * FROM TransferMarkt_sp20.PlayerPositions WHERE PlayerID = ?', 
		[req.params.id], (error, results, field) => {
        if (error) 
        {
            res.status(404).send(error);
            return;
        }
        res.send(JSON.stringify({ "status": 200, "error": null, "response": results }));
    });

    // carry on with queries if token is verified
    jwt.verify(req.token, skey, (err, userData) => {
        if (err && !debug) {res.status(404).send("Invalid JWT Token");}
        else {
            console.log(userData);
            my_query();
        }
    });
});

// Get position info for a position ID
// GET single player:
router.get("/api/positions/:id", verifyToken, (req, res, next) => {
    if (isNaN(req.params.id))
    {
        res.status(404).send("Player ID needs to be an INT.");
        return;
    }

    var my_query = () => global.connection.query('SELECT * FROM TransferMarkt_sp20.Positions WHERE PositionID = ?', 
		[req.params.id], (error, results, field) => {
        if (error)
        {
            res.status(404).send(error);
            return;
        } 
            
        res.send(JSON.stringify({ "status": 200, "error": null, "response": results }));
    });

    // carry on with queries if token is verified
    jwt.verify(req.token, skey, (err, userData) => {
        if (err && !debug) {res.status(404).send("Invalid JWT Token");}
        else {
            console.log(userData);
            my_query();
        }
    });
});

// Get general position info (position ID, position name)
// GET single player:
router.get("/api/positions/", verifyToken, (req, res, next) => {
    var my_query = () => global.connection.query('SELECT * FROM TransferMarkt_sp20.Positions', 
		[], (error, results, field) => {
        if (error) res.status(404).send(error);
        else res.send(JSON.stringify({ "status": 200, "error": null, "response": results }));
    });

    // carry on with queries if token is verified
    jwt.verify(req.token, skey, (err, userData) => {
        if (err && !debug) {res.status(404).send("Invalid JWT Token");}
        else {
            console.log(userData);
            my_query();
        }
    });
});



// GET Single Club:
router.get("/api/clubs/:id", verifyToken, (req, res, next) => {
    // check if ID is int
    if (isNaN(req.params.id))
    {
        res.status(404).send("Club ID needs to be INT.");
        return;
    }
    console.log("getting single club, req params id: "+req.params.id);
    var my_query = () => global.connection.query('SELECT * FROM TransferMarkt_sp20.Clubs WHERE ClubID = ?', 
		[req.params.id], (error, results, field) => {
        if (error) res.status(404).send(error);
        // console.log("players got: "+ JSON.stringify(results));
        else res.send(JSON.stringify({ "status": 200, "error": null, "response": results }));
    });

    // carry on with queries if token is verified
    jwt.verify(req.token, skey, (err, userData) => {
        if (err && !debug) {res.status(404).send("Invalid JWT Token");}
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
        if (error) res.status(404).send(error);
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


// GET Trade by ID:
router.get("/api/trade/:id", verifyToken, (req, res, next) => {
    // check if ID is string
    if (typeof req.params.id !== 'string') { req.params.id = String(req.params.id); }

    var my_query = () => global.connection.query('SELECT * FROM TransferMarkt_sp20.Requests WHERE PackageID = ?', 
    [req.params.id], (error, results, field) => {
       if (error) res.status(404).send(error);
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
  
    var my_query = (userData) => global.connection.query('SELECT p.PackageID, p.Status, p.Date FROM TransferMarkt_sp20.Packages p, TransferMarkt_sp20.Signatures s WHERE p.PackageId = s.PackageId AND p.Status = 1 AND s.ClubID = ? AND s.Status = ? ORDER BY p.Date DESC', 
    [userData.user.clubId, -1], (error, results, field) => {
       if (error) res.status(404).send(error);
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
    // check if ID is number
    if (isNaN(req.params.id))
    {
        res.status(404).send("Club ID needs to be INT.");
        return;
    }

    var my_query = () => global.connection.query('SELECT t.PackageID, t.DateSigned FROM TransferMarkt_sp20.Transfers t, TransferMarkt_sp20.Signatures s WHERE t.PackageID = s.PackageID AND s.ClubID = ? ORDER BY t.DateSigned DESC LIMIT 10', 
    [req.params.id], (error, results, field) => {
       if (error) res.status(404).send(error);
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
    var my_query = () => global.connection.query('SELECT * FROM TransferMarkt_sp20.Transfers ORDER BY DateSigned DESC LIMIT 10', 
    [], (error, results, field) => {
       if (error) res.status(404).send(error);
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
    if (isNaN(req.params.id))
    {
        res.status(404).send("Player ID needs to be INT.");
        return;
    }

    var query_str = `UPDATE TransferMarkt_sp20.Players SET ? WHERE playerId = ?`;

    var response = {"UpdatePlayer" : false, "UpdatePosition" : false};

    var clear_and_update = (positions, playerId) =>
        global.connection.query('DELETE FROM TransferMarkt_sp20.PlayerPositions WHERE PlayerID = ?', [playerId], (error, results, field) => {
            if (error) res.status(404).send(error);
            else update_position(positions, 0, playerId);
        });

    var update_position = (positions, index, playerId) => {
        // clear player's positions before updating
        if (index == positions.length)
            global.connection.commit((error) => {
                if (error) res.status(404).send(error);
                else
                {
                    response.UpdatePosition = true;
                    res.send(JSON.stringify({ "status": 200, "error": null, "response": response}));
                }
            });
        else
            global.connection.query('INSERT INTO TransferMarkt_sp20.PlayerPositions VALUES(?)', [[playerId, positions[index]]], (error, results, field) => {
                if (error)
                    global.connection.rollback(()=>
                    {
                        res.status(404).send(error);
                    });
                else 
                {
                    update_position(positions, index + 1, playerId);
                }
            });
    };

    var update_player = (clubId) => global.connection.query(query_str, [req.body.Player, Number(req.params.id)], (error, results, field) => {
        if (error)
            global.connection.rollback(() =>
            { 
                res.status(404).send(error);
            });
        else
            checkClubValidity(clubId, (isValid) => {
                if (isValid)
                {
                    response.UpdatePlayer = true;
                    if ("Positions" in req.body)
                        if (Array.isArray(req.body.Positions))
                            clear_and_update(req.body.Positions, req.params.id);
                        else
                            global.connection.rollback((error)=>
                            {
                                if (error) res.status(404).send(error);
                                else res.status(404).send("Positions value needs to be an array type.");
                            });
                    else
                        global.connection.commit((error) => {
                            if (error) res.status(404).send(error);
                            else res.send(JSON.stringify({ "status": 200, "error": null, "response": response}));
                        });
                }
                else
                {
                    global.connection.rollback(() =>
                    {
                        console.log("salary cap violation.");
                        res.send(JSON.stringify({ "status": 200, "error": null, "response": "Update Failed Due to Salary Cap Violation."}));
                    });
                }
            });
    });

    var my_query = (clubId) => global.connection.beginTransaction((err) => {
        if (err) throw err;
        console.log(clubId);
        update_player(clubId);
    });

    // only allow if player belongs to the manager's club
    jwt.verify(req.token, skey, (err, userData) => {
        if (err && !debug) res.status(404).send("Invalid JWT Token");
        else 
            verifyClub(req.params.id, userData.user.clubId, my_query, userData.user.clubId, res);
    });
});

// Sign Trade Package
router.put("/api/sign/:id", verifyToken, (req, res) => {

    // insert to transfer table if package is approved
    var response = {Approved : false};

    var insert_to_transfer = () => global.connection.query('INSERT INTO TransferMarkt_sp20.Transfers VALUES(?, CURRENT_TIMESTAMP)', [req.params.id], (error, results, field) => {
        if (error) res.status(404).send(error);
        else
        {
            response.Approved = true;
            res.send(JSON.stringify({"status" : 200, "error" : null, "response" : response}));
        }
    });

    // status = -1 (pending), 0 (rejected), 1(accepted)
    // when sum(status) == count(status), the trade package has been accepted by all clubs, hence approved.
    var check_complete = (next) => global.connection.query('SELECT COUNT(Status) AS Sum, COUNT(Status) = SUM(Status) AS Approved FROM TransferMarkt_sp20.Signatures WHERE PackageId = ?', [req.params.id], (error, results, field) => {
        if (error) res.status(404).send(error);
        else 
            if (results.length === 0 || typeof results === undefined)
                res.status(404).send("Package ID NOT FOUND.");
            else {
                var rows = JSON.parse(JSON.stringify(results[0]));
                if (rows.Approved) {                    
					// Check if trade package is valid
					execute_trade(req.params.id, success => {
                        
                        if (success) next();
					    else {
                            // Invalidate the Package:
                            global.connection.query('UPDATE TransferMarkt_sp20.Packages SET Status = Status * ? WHERE PackageId = ?', [0, req.params.id], (error, results, field) => {
                                if (error) res.status(404).send(error);
                                else (!res.headersSent)? res.send(JSON.stringify({"status" : 200, "error" : null, "response" : response})) : console.log(response);
                            });
                        }
                    }); 
				}
                else res.send(JSON.stringify({"status" : 200, "error" : null, "response" : response}));
            }
    });

    // update package status
    var update_package = () => global.connection.query('UPDATE TransferMarkt_sp20.Packages SET Status = Status * ? WHERE PackageId = ?', [req.body.status, req.params.id], (error, results, field) => {
        if (error) res.status(404).send(error);
        else
            console.log(`Package ${req.body.status} Status Updated.`);
    });
    
    // update signature entry
    var update_signature = (u) => global.connection.query('UPDATE TransferMarkt_sp20.Signatures SET Status = ? WHERE PackageId = ? AND ClubId = ?', [req.body.status, req.params.id, u.clubId], (error, results, field) => {
        if (error) res.status(404).send(error);
        else 
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
    console.log(req.body);
    for(const attrib of player_attribs)
        if (!req.body.hasOwnProperty(attrib))
            {
                res.status(404).send(`${attrib} not found in body`);
                return;
            }
    
    var player = createPlayer(req.body);
    var response = {CreatePlayer : false, UpdatePosition : false};

    var new_player = () => global.connection.query('INSERT INTO TransferMarkt_sp20.Players VALUES(?)', [Object.values(player)], (error, results, field) => {
        if (error)
            global.connection.rollback(() =>
            { 
                res.status(404).send(error);
            });
        else
            checkClubValidity(player.ClubID, (isValid) => {
                if (isValid)
                {
                    global.connection.commit((error) =>
                    {
                        if (error)
                        {
                            res.status(404).send(error);
                            return;
                        }
                        response.CreatePlayer = true;            
                        update_position(req.body.Positions, 0, results.insertId);
                        res.send(JSON.stringify({ "status": 200, "error": null, "response": results }));
                    });
                }
                else
                {
                    global.connection.rollback(() =>
                    {
                        res.send(JSON.stringify({ "status": 200, "error": null, "response": "Update Failed Due to Salary Cap Violation."}));
                    });
                }
            });
    });

    var my_query = () => global.connection.beginTransaction((err) => {
        if (err) throw err;
        new_player();
    });

    var update_position = (positions, index, playerId) => {
        if (index == positions.length)
            return;
        else
            global.connection.query('INSERT INTO TransferMarkt_sp20.PlayerPositions VALUES(?)', [[playerId, positions[index]]], (error, results, field) => {
                if (error) res.status(404).send(error);
                else 
                {
                    response.UpdatePosition = true;
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
                my_query();
        }
    });
});

// Make Trade Package Request
router.post("/api/trade/", verifyToken, (req, res) => {
    // Check if body contains requests
    if (!("requests" in req.body) || !Array.isArray(req.body.requests))
    {
        res.status(404).send("Body Missing Requests Field or Requests is not an array");
        return;
    }

    var packageID = uuidv1();

    var teams = new Set();
    var halt = false;
    var response = {PackageID : packageID};

    var create_requests = () => req.body.requests.forEach((request, index, array) =>
    {
        // Check if a request has all necessary attributes
        for (const attrib of request_attribs)    
            if (!request.hasOwnProperty(attrib))
                {
                    res.status(404).send(`Request missing ${attrib}.`);
                    halt = true;
                    return;
                }
        
        if (halt)
            return;

        verifyClub(request.PlayerID, request.From, () =>
            global.connection.query('INSERT INTO TransferMarkt_sp20.Requests VALUES(?)', [Object.values(createRequest(request, packageID))], (error, results, field) => {
                console.log("insert results: " + JSON.stringify(results));
                if (error)
                {
                    console.log(error);
                    if (!res.headersSent)     
                        res.status(404).send(error);
                }
                else
                {
                    if(!teams.has(request.To))
                    {
                        teams.add(request.To);
                        global.connection.query('INSERT INTO TransferMarkt_sp20.Signatures VALUES(?)', [Object.values(createSignature(request.To, packageID))], (error, results, field) => {
                            if (error)
                            {
                                res.status(404).send(error);
                                return;
                            }
                        });
                    }
                    if (!teams.has(request.From))
                    {
                        teams.add(request.From);
                        global.connection.query('INSERT INTO TransferMarkt_sp20.Signatures VALUES(?)', [Object.values(createSignature(request.From, packageID))], (error, results, field) => {
                            if (error)
                            {
                                res.status(404).send(error);
                                return;
                            }
                        });
                    }
    
                    if (index == array.length - 1 && !res.headersSent)
                    {
                        res.send(JSON.stringify({"status" : 200, "error" : null, "response" : response}));
                    }
                }
        }), null, res);
    });

    // trade package status defaulted to be accepted for easier backend processing (0 = rejected, 1 = accepted)
    var create_trade = () => global.connection.query('INSERT INTO TransferMarkt_sp20.Packages VALUES(?)', [Object.values(createPackage(packageID))], (error, results, field) => {
        if (error) res.status(404).send(error);
        else
            create_requests();
    });

    jwt.verify(req.token, skey, (err, userData) => {
        if (err && !debug) res.status(404).send("Invalid JWT Token");
        else
        {
            create_trade();
        }    
    });

});

// DELETE
// Delete player info
router.delete("/api/players/:id", verifyToken, (req, res) => {
    // Check if id is int
    if (isNaN(req.params.id))
    {
        res.status(404).send("Player ID needs to be INT.");
        return;
    }
    delete_positions = () => global.connection.query('DELETE FROM TransferMarkt_sp20.PlayerPositions WHERE PlayerID = ?', [req.params.id], (error, results, field) => {
        if (error) res.status(404).send(error);
        else delete_player();
    });

    // callback to delete if admin
    delete_player = () => global.connection.query('DELETE FROM TransferMarkt_sp20.Players WHERE playerId = ?', [Number(req.params.id)], (error, results, field) => {
        console.log(error);
        if (error) res.status(404).send(error);
        else res.send(JSON.stringify({"status" : 200, "error" : null, "response" : results}));
    });
    
    jwt.verify(req.token, skey, (err, userData) => {
        if (err && !debug) { res.status(404).send("Invalid JWT Token");}
        else {
            console.log(userData);
            // allow only if the player belongs to the admin's club
            verifyClub(req.params.id, userData.user.clubId, delete_positions, null, res);
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
    };

    global.connection.query("SELECT SaltedPassword, ClubID, AdminPrivilege FROM TransferMarkt_sp20.Managers WHERE Username = ?", [user.username], (error, results, fields) => {
        if (error)
        {
            res.status(404).send(error);
            return;
        }
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
                if (error) {
                    res.status(404).send(error);
                    return;
                }
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

