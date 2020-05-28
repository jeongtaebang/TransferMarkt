# Using the AWS Instance to Host Backend:

### Logging In:
1. `chmod 400 transfermarkt.pem`
2. `ssh -i ./path/to/transfermarkt.pem ubuntu@100.25.141.132`

### Updating the DB:
The database is permissioned to push/pull to the backend or frontend repos, but note that pushes will be made under my (kenneym) username. The latest `npm` is installed via `nvm`.

### Running the Backend:
Since another user might already be running the DB, make sure to kill all node instances before relaunching the db:
1. `sudo fuser -k -n tcp 3000`
2. `node api.js`

Same process applies for the frontend if you want to run the frontend on the server as well.

### Accessing the Backend:
Simply replace localhost with `100.25.141.132` in your API calls.
