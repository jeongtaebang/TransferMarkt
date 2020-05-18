# TransferMarkt

## Schema Folder:
- `create_transfermarkt_schema.sql`: the script used to generate the database schema. Modified from the original forward engineering script to reflect MariaDB syntax (Sunapee is MariaDB).
- `transfermarkt.mwb`: Model used to forward engineer the database.
- `data_prep.ipynb`: python notebook to generate data for the schema and import it into the database.
- `data_prep.py`: python script - direct translation of the notebook.
- `players_20.csv`: FIFA Video game data on all current (2020) soccer players used to generate the database. Taken from [kaggle](https://www.kaggle.com/stefanoleone992/fifa-20-complete-player-dataset).
- `manager_creds.csv`: Username and passwords of all managers in our DB. Stored in CSV for reference (since plaintext passwords are not stored in the database itself).
