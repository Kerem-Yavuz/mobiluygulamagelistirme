var mysql = require('mysql');
var express = require("express");
const crypto = require('crypto');
const jwt = require('jsonwebtoken');
var app = express();
var path = require('path');
var cookieParser = require('cookie-parser');

const JWT_SECRET = '7324f7115b13969bb06d94dfb332ef216383aa29700b460a72b3baef689ff6bfdb6aaf1fda8a0adfe0d2111663b49bce5d71ffb43bbbcd115c52a029313bafa6a9188f666b5809b86326529d4d1a0790923d4d613f54913fbfa6b6a3c4d4db5fa37037ccd9ace700fd238b92facf4bc54ec8cf93d8d7fc9fcd6e339656159f4ee5f692bcc6e8e48915e4c0f26fd45b6f6f6df3be0460ca7c0e2ee2cd0029d934b662409a4c57073437e7b7635ce7f6c54ae5298bee463ac6005651238d96e90b821277b9252258b511fb496b8f52fc7081c968b6887e5117d3b96dc40c5348e7b6d525724e89769c0022bb44ae8b642713ffc65fa0fd0db34660d1ffddf72060'; // Change this to a strong secret key

app.set('view engine', 'ejs');
app.use(express.static(path.join(__dirname,"/public")));
app.use(cookieParser());


var con = mysql.createConnection({//mysql connections
    host: "localhost",
    user: "root",
    password: "Mysql123!",
    database: "mobiluygulamagelistirme",
    port: 3306
    });

con.connect(function(err) {
        if (err) throw err;
        console.log("Connected to MySQL database!");
    });

app.use(express.urlencoded({ extended: true }));
app.use(express.json());

function isAuthenticated(req, res, next) {
    const token = req.cookies.token;
    if (!token) {
        return res.send("Send Token");
    }

    jwt.verify(token, JWT_SECRET, (err, decoded) => {
        if (err) {
            res.clearCookie('token');
            return res.send("jwt error")
        }
        req.user = decoded;
        next();
    });
}

app.use((req, res, next) => {
    if (req.cookies.token) {
        try {
            const decoded = jwt.verify(req.cookies.token, JWT_SECRET);
            req.user = decoded; // Set the decoded token as req.user
        } catch (err) {
            res.clearCookie('token');
            return res.send("please send token");
        }
    }
    next();
});


app.get("/login/check", (req, res) => {
    const person = {
        username: req.query.username,
        password: req.query.password
    };
    let hashedPassword = hashPassword(person.password);// hashes the inputed password
    let query = 'SELECT * FROM users WHERE BINARY user_Name = ?;';
    let name = [person.username];
    
    con.query(query, name, function (err, results) {
        if (err) {
            return res.status(500).send('Database query failed.');
        }
        if (results.length === 1) {
            let sqlStoredHashedPassword = results[0].user_Password; // we have already get the password with the first query so we are just checking it here

            if (sqlStoredHashedPassword === hashedPassword) {
                const token = jwt.sign({ username: person.username, id: results[0].userID }, JWT_SECRET, { expiresIn: '30d' });// creates token 
                res.cookie('token', token, { httpOnly: true }); //stores that token in cookie
                res.status(200).json({success: "success"});
            } else {//Wrong password
                res.status(400).json({error: "Wrong pass or username"});
            }
        } else {//Wrong username
            res.status(400).json({error: "Wrong pass or username"});
        }
    });
});


app.get("/signup/check", (req,res)=>
{
    const person =
    {
        username: req.query.username,
        password: req.query.password
    }
    let usercheck = 'SELECT * FROM users WHERE BINARY user_Name = ?;';
    let name = [person.username];
    let hashedPassword = hashPassword(person.password);

    con.query(usercheck, name, function (err, results) {
        if (err) {
            return res.status(500).send('Database query failed.');
        }
        
        if (results.length > 0) {
            return res.send("Bu Kullanıcı adı bulunuyor, giriş yapın yada başka bir kullanıcı adı seçin");
        } else {
            let createUserQuery = `INSERT INTO users VALUES(0,"${person.username}","${hashedPassword}",3);`;// Creates user with person.username, person.password , groupID = 2 , and the automatic userID

            con.query(createUserQuery, function (err, result) {
                if (err) {
                    console.error("Failed to create user:", err);
                    return res.status(500).send("Failed to create user");
                }
                return res.status(200).json({message: "success"})
            });
        }
    });
});



function hashPassword(password) {
    // Hash the password with SHA-1 in binary format
    const firstHashBinary = crypto.createHash('sha1').update(password, 'utf8').digest('binary');

    // Hash the binary hash with SHA-1 again and output in hexadecimal format
    const secondHashHex = crypto.createHash('sha1').update(firstHashBinary, 'binary').digest('hex');

    // Format the result: uppercase and prepend an asterisk
    return '*' + secondHashHex.toUpperCase();
}

let port = 8001;
let ip = "0.0.0.0";

let server = app.listen(port,ip, (error) => {
if(error) throw error;
    console.log("Server is running on:",ip, port);
});
