#!/usr/bin/env python
# coding: utf-8

# # CS60 Database Schema Construction
import pandas as pd
import numpy as np
import sqlalchemy as db
from pandas.io import sql
from text_unidecode import unidecode
import bcrypt


# ## Read in Data
players = pd.read_csv("./players_20.csv", usecols=['short_name', 'long_name', 'age', 'height_cm', 
                                                   'weight_kg', 'club', 'player_positions', 'overall'])

# ## Manipulate Data to reflect our schema

# #### Add Data Categories to Players to match our Schema and Select only players from La Liga Series A

players['first_name'] = players['long_name'].str.split().str[0]
players['last_name'] = players['long_name'].str.split().str[1:]
players['last_name'] = players['last_name'].apply(" ".join)

# Decode any strange characters:
players['first_name'] = players['first_name'].apply(unidecode)
players['last_name'] = players['last_name'].apply(unidecode)

# Generate Player salaries by using overall player score from FIFA:
players['overall'] /= 10 # divide by 10 and consider player ranking a log scale to generate salaries
players['salary'] = (2.9**players['overall'] * 500).astype(int)

# Select only players in the La Liga Clubs selected for our database
db_clubs = ['FC Barcelona', 'Atlético Madrid', 'Real Betis', 
            'Granada CF', 'Real Madrid','Valencia CF', 
            'Real Sociedad', 'Sevilla FC','Villarreal CF',
            'Getafe CF', 'Athletic Club de Bilbao',
            'CA Osasuna', 'Levante UD', 'Deportivo Alavés',
            'Real Valladolid CF', 'SD Eibar', 'RC Celta', 
            'RCD Mallorca', 'CD Leganés', 'RCD Espanyol']

players = players[players['club'].isin(db_clubs)]
print("Clubs remaining:", players['club'].nunique())

# Create AUTO_INCREMENT id:
players.reset_index(inplace=True, drop=True)
players.reset_index(level=0, inplace=True)
players['index'] += 1


# #### Generate Club Table, and dictionary to map Club Names to IDs within the players table

# Convert Club Names into ClubIDs
club_dict = {k: v + 1 for v, k in enumerate(db_clubs)} # converts club name to clubID
players['club'] = players['club'].apply(lambda club: club_dict[club]) # convert within dataframe

# create a club dataframe to go along with the players dataframe:
clubs = pd.DataFrame(db_clubs, columns=['ClubName'])
clubs.reset_index(level=0, inplace=True)
clubs['LeagueID'] = 1
clubs = clubs.rename(columns={"index": "ClubID"})

# Start from one for autoincrement purposes:
clubs['ClubID'] += 1

clubs.head()


# Generate position dataframe & id dictionary
def unique(list1): 
    x = np.array(list1) 
    return np.unique(x) 

# Create lookup table
pos_list = unique(players['player_positions'].str.split(',').str[0])
pos_dict = {k: v + 1 for v, k in enumerate(pos_list)} # converts club name to clubID

# Create Club Dataframe
positions = pd.DataFrame(pos_list, columns=['PositionName'])
positions.reset_index(level=0, inplace=True)
positions = positions.rename(columns={"index": "PositionID"})
positions['PositionID'] += 1
positions.head()


# #### Break PlayerPositions column into dataframe PlayerPositions (Normalize the DB)

# Extract Data
player_positions_list = [] # list of dictionaries representing each player position relationship
for _, player in players.iterrows():
    for position in player['player_positions'].split(','):
        player_position = {}
        player_position['PlayerID'] = player['index']
        player_position['PositionID'] = pos_dict[position.strip()] # returns the position ID
        player_positions_list.append(player_position)
        
        
# Create the PlayerPositions Table:
player_positions = pd.DataFrame(data=player_positions_list)
player_positions.head()


# #### Players table now complete - remove unnessesary columns to finalize

# Remove unnessesary data
players = players[['index', 'first_name', 'last_name', 'age', 'club', 'salary']]
players = players.rename(columns={"index": "PlayerID", "first_name": "FirstName", "last_name": "LastName",
                                  "club": "ClubID","salary": "Salary", "age": "Age"})

# Create Clubs DF (150 Million Salary Cap)
leagues = pd.DataFrame([{'LeagueID': 1, 'LeagueName': 'La Liga Series A', 
                         'SalaryCap': 115000000}])

# Create Managers DF
usernames = ['chloeozzy','muttiesreeping','poppyovercast','refluxanthology','ludibriousjump',
             'wekivadesk','coalitionpolicy','crierbedswerver','publishernutcracker','execbusan',
             'booeshairs','pebbleswarming','tarffcareers','irateflotilla','villagegregarious',
             'borsezipping','oppressedelderly','datastatute','chopinenzyme','spellingjob']

passwords = ['walk51song','systemprobable78','surprisehe93','migrate13state','26liesudden',
             'garden64any','gather13sugar','create86bit','hugereach59','11groundbeen',
             'see46bring','48answeralso','79toldjoin','16companyword','control9fly',
             'pagewood56','root15there','73deepstation','object27bacon','governpractice71']

managers_list = [] # list of dictionaries representing each manager

# Generate Manager Data
for i in range(len(usernames)):
    manager = {}
    manager['ManagerID'] = i + 1
    manager['ClubID'] = i + 1
    manager['Username'] = usernames[i]
    manager['AdminPrivilege'] = 1
    
    # Keep Plaintext password so we can write to a record (will drop before placing into DB)
    manager['Password'] = passwords[i]
    bytes_password = passwords[i].encode()
    
    # decode to convert from bytes literal to UTF-8 string
    manager['SaltedPassword'] = bcrypt.hashpw(bytes_password, bcrypt.gensalt(rounds=12)).decode()
    
    managers_list.append(manager)
    
    
# Create the Manager Table:
managers = pd.DataFrame(data=managers_list)

# Save Manager Info for Reference:
managers.to_csv("manager_creds.csv", index=False)
managers = managers.drop("Password", axis=1)


# ## Populate the SQL Database
# db = db.create_engine('mysql+mysqldb://TransferMarkt_sp20:V2LK^ep$@sunapee.cs.dartmouth.edu:3306/TransferMarkt_sp20', pool_recycle=3600)

# Uncomment the following to use AWS instead of sunapee:
db = db.create_engine('mysql+mysqldb://TransferMarkt:CQ97PTVOiPQWwlhdtLHo@transfermarkt.cdcl1ioqlhoa.us-east-1.rds.amazonaws.com:3306/TransferMarkt_sp20', pool_recycle=3600)


# #### Insert Tables (inserted in order to satisfy FK constraints)

leagues.to_sql(con=db, name='Leagues', if_exists='append', index=False)
clubs.to_sql(con=db, name='Clubs', if_exists='append', index=False)
players.to_sql(con=db, name='Players', if_exists='append', index=False)
positions.to_sql(con=db, name='Positions', if_exists='append', index=False)
player_positions.to_sql(con=db, name='PlayerPositions', if_exists='append', index=False)
managers.to_sql(con=db, name='Managers', if_exists='append', index=False)

