var express = require('express');
let mysql = require('mysql');
var app = express();
const bodyParser = require('body-parser');
var config = require('./config');
let jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const { v1: uuidv1 } = require('uuid');
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
    // const tokHeader = req.headers['authorization'];
    // if (typeof tokHeader !== undefined) {
    //     const bearer = tokHeader.split(' ');
    //     const token = bearer[1];
    //     req.token = token;
        next();
    // } else {
    //     res.status(404).send("Permission denied");
    // }
}


// Match Player Club Id with User's Club Id
var verifyClub = (playerId, clubId, next) => global.connection.query("SELECT clubId FROM TransferMarkt.players WHERE playerId = ?", [playerId], (error, results, fields) => {
    if (error) throw error;
    console.log(results);
    
    if (results.length === 0 || typeof results === undefined) {
        res.status(404).send("Wrong ID or Password");
    } else {
        var rows = JSON.parse(JSON.stringify(results[0]));
        
        rows.clubId == userData.user.clubId ? next() : res.status(404).send("Permission Denied.");
    }
});


// GET players
router.get("/api/players/", verifyToken, (req, res, next) => {
    var FirstName = ("FirstName" in req.params)? req.params.FirstName : "";
    var LastName = ("LastName" in req.params)? req.params.LastName : "";


    var my_query = () => global.connection.query('SELECT * FROM TransferMarkt_sp20.players WHERE FirstName LIKE ? AND LastName LIKE ?', [`%${FirstName}%`, `%${LastName}%`], (error, results, field) => {
        if (error) throw error
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
    var ClubName = ("ClubName" in req.params)? req.params.ClubName : "";
    var ClubId = ("ClubID" in req.params)? req.params.ClubID : "";

    var my_query = () => global.connection.query('SELECT * FROM TransferMarkt_sp20.clubs WHERE ClubName LIKE ? AND ClubID LIKE ?', [`%${ClubName}%`, `%${ClubId}%`], (error, results, field) => {
        if (error) throw error
        res.send(JSON.stringify({ "status": 200, "error": null, "response": results }));
    });

    // carry on with queries if token is verified
    // jwt.verify(req.token, skey, (err, userData) => {
    //     if (err) res.status(404).send("Invalid JWT Token");
    //     else {
    //         console.log(userData);
            my_query();
    //     }
    // });
});

// PUT
// Update Player Info
router.put("/api/players/:id", verifyToken, (req, res) => {
    var attrib = req.body.attrib;
    var params = [req.body.value, req.body.club]
    
    var query_str = `UPDATE TransferMarkt_sp20.players SET %${req.body.attrib}% = ? WHERE playerId = ?`

    var my_query = () => global.connection.query(query_str, [req.params.id], (error, results, field) => {
        if (error) throw error
        res.send(JSON.stringify({ "status": 200, "error": null, "response": results }));
    });
    // only allow if player belongs to the manager's club
    jwt.verify(req.token, skey, (err, userData) => {
        if (err) { res.status(404).send("Invalid JWT Token") }
        else verifyClub(req.params.id, userData.clubId, my_query);
    });
});

// POST
// New Player
router.post("/api/players/", verifyToken, (req, res) => {
    var my_query = () => global.connection.query('INSERT INTO TransferMarkt.players VALUES(?, ?, ?, ?, ?, ?)', [null, req.body.FirstName, req.body.LastName, req.body.Age, req.body.ClubId, req.body.Salary], (error, results, field) => {
        if (error) throw error;
        res.send(JSON.stringify({"status" : 200, "error" : null, "response" : results}));
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
router.post("/api/request/", verifyToken, (req, res) => {
    
    var packageId = uuidv1();

    var create_requests = () => req.body.requests.forEach((request)=>
        global.connection.query('INSERT INTO TransferMarkt.Requests VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)', [null, req.body.packageId, req.body.from, req.body.to, req.body.playerId, req.body.type, req.body.transfer_fee, req.body.salary, req.body.date], (error, results, field) => {
            if (error) throw error;
            res.send(JSON.stringify({"status" : 200, "error" : null, "response" : results}));
        }));

    var create_trade = () => global.connection.query('INSERT INTO TransferMarkt.TradePackage VALUES(?, ?)', [packageId, 0], (error, results, field) => {
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
    admin_query = () => global.connection.query('DELETE FROM TransferMarkt_sp20.players WHERE playerId = ?', [req.params.id], (error, results, field) => {
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


// // LOGIN
router.post("/api/login/", (req, res) => {
    var user = {
        username: req.body.login_username, 
        pw: req.body.login_password,
        is_admin: false
    }
    global.connection.query("SELECT password, clubId, privilege FROM TransferMarkt_sp20.users WHERE Username = ?", [user.username], (error, results, fields) => {
        if (error) throw error;
        console.log(results);

        if (results.length === 0 || typeof results === undefined) {
            res.status(404).send("Wrong ID or Password");
        } else {
            var rows = JSON.parse(JSON.stringify(results[0]));

            bcrypt.compare(user.pw, rows.password, (error, result) => {
                if (error) throw error;
                if (result) {
                    user.privilege = privilege;
                    user.clubId = clubId;

                    jwt.sign({ user }, skey, { expiresIn: '1h' }, (err, token) => {
                        if (err) throw err;
                        res.send(JSON.stringify({ "status": 200, "error": null, "response": token }));
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