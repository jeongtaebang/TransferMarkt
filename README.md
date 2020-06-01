# TransferMarkt
## Introduction:
Our application is a central management hub that can be used by soccer league managers in order to monitor their clubs and manage intra-league player transfers. Our system can be used by club managers to make and accept transfer requests. Each manager can view his / her incoming & outgoing pending requests and completed requests. The system has business logic built-in to update player information automatically as transfers are made (i.e. updating player information to reflect the new club that a player has been traded to, the new salary, etc.). The system rejects packages that cause involved clubs to violate the league’s salary cap, and requires that all clubs involved in a trade sign off before that trade is executed. In addition to enabling managers to view, create, and sign player transfers, the system allows managers to view their own club’s players, search the league for other players, or view other soccer club information.  

Potentially, sports league organizations can use this application to manage information during their transfer windows. In the future, the application may be extended to form a network of transfer systems consisting of multiple leagues that can handle inter-league transfers.  


## Schema Folder:
- `create_transfermarkt_schema.sql`: the script used to generate the database schema. Modified from the original forward engineering script to reflect MariaDB syntax (Sunapee is MariaDB).
- `transfermarkt.mwb`: Model used to forward engineer the database.
- `data_prep.ipynb`: python notebook to generate data for the schema and import it into the database.
- `data_prep.py`: python script - direct translation of the notebook.
- `players_20.csv`: FIFA Video game data on all current (2020) soccer players used to generate the database. Taken from [kaggle](https://www.kaggle.com/stefanoleone992/fifa-20-complete-player-dataset).
- `manager_creds.csv`: Username and passwords of all managers in our DB. Stored in CSV for reference (since plaintext passwords are not stored in the database itself).

## How to Use:
We have a server running on AWS. You may log in at `http://transfermarkt.live/signin`. Please contact us for credentials.  s

Gillian Yue  
Jeong Tae Bang  
Matthew Kenney  
Sung Jun Park  
