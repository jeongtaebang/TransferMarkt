# TransferMarkt
**Contributors**: Gillian Yue, Jeong Tae Bang, Matthew Kenney, Sung Jun Park

## Introduction:
Our application is a central management hub that can be used by soccer league managers in order to monitor their clubs and manage intra-league player transfers. Our system can be used by club managers to make and accept transfer requests. Each manager can view his / her incoming & outgoing pending requests and completed requests. The system has business logic built-in to update player information automatically as transfers are made (i.e. updating player information to reflect the new club that a player has been traded to, the new salary, etc.). The system rejects packages that cause involved clubs to violate the league’s salary cap, and requires that all clubs involved in a trade sign off before that trade is executed. In addition to enabling managers to view, create, and sign player transfers, the system allows managers to view their own club’s players, search the league for other players, or view other soccer club information.  

Potentially, sports league organizations can use this application to manage information during their transfer windows. In the future, the application may be extended to form a network of transfer systems consisting of multiple leagues that can handle inter-league transfers.  

## Schema Folder:
- `TransferMarkt_dump.sql`: Our database export.
- `create_transfermarkt_schema.sql`: The script used to generate the database schema (may need to be modified before running on MariaDB database).
- `TransferMarkt_sp20.mwb`: Model used to forward engineer the database.
- `data_prep.ipynb`: Python notebook to generate data for the schema and import it into the database.
- `data_prep.py`: Python script - direct translation of the notebook.
- `players_20.csv`: FIFA Video game data on all current (2020) soccer players used to generate the database. Taken from [kaggle](https://www.kaggle.com/stefanoleone992/fifa-20-complete-player-dataset).
- `manager_creds.csv`: Username and passwords of all managers in our DB. Stored in CSV for reference (since plaintext passwords are not stored in the database itself). The manager in row 1 is the manager for club 1 (FC Barcelona), the manager in row 2 is the manager for club 2, and so on.

## Backend Folder:
- `api.js`: Our central node backend which hosts all of the API endpoints.
- `config.js`: The config file neccessary to connect to sunapee - change the config to the config file of your choice in `api.js` (see `var config = require('./config-filename')`).
- `config-aws.js`: The config file to connect to our Amazon RDS database.
- `package.json`: Node requirements and configuration.


## Running on localhost:
- Create a new database by using the `TransferMarkt_dump.sql` file. Alternatively you can run `create_transfermarkt_schema.sql` to generate the database schema, and then populate the database with the original FIFA data by running `python3 data_prep.py` from the Schema directory. Make sure to change the database connection used in `data_prep.py` (see the line with `db = db.create_engine` towards the bottom of the script).
- Edit `config.js` to match your new database and edit `api.js` such that `var config = require('./config')`.
- Run `node api.js` in the Backend directory to start the backend.
- Start the front end with `yarn start` (see seperate front end github repo `https://github.com/GillianYue/61_frontend` for details).

## Website:
We have a server running on AWS hosting our application. You may log in using manager credentials at `http://transfermarkt.live/signin`. This website will be taken down shortly after the end of Dartmouth's Spring Term 2020.
