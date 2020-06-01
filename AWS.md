# Using the AWS Instance to Host Backend:

### Logging In:
1. `chmod 400 transfermarkt.pem`
2. `ssh -i ./path/to/transfermarkt.pem ubuntu@100.25.141.132`

### Updating the DB:
The database is permissioned to push/pull to the backend or frontend repos, but note that pushes will be made under my (kenneym) username. The latest `npm` is installed via `nvm`.

### Running the Backend:
Since another user might already be running the DB, make sure to kill all node instances before relaunching the db:
1. `sudo fuser -k -n tcp 3000`
2. Run api.js:
 - `node api.js` if you plan to keep the connection the the server open and want to test actively
- `nohup node api.js &` if you want the backend to remain up even after your connection to the server drops.

### Running the Front End:
1. Alter the URL found in /src/actions/index.js from http://localhost:3000/api to http://100.25.141.132:3000/api
2. npm install -g serve
3. yarn build in the root directory of the front end codebase
4. You cannot bind to low ports without root permissions... however, root does not have access to the user-level programs that node and yarn use. In order to keep the front end alive indefinetly, you can pass sudo your user environment path and have it run "serve" for you on port 80. This will make the front end available in the outside world: `sudo env "PATH=$PATH" nohup serve -s build -l 80`

To later kill the server, run `sudo fuser -k -n tcp 80`.

### Accessing the Backend:
Simply replace localhost with `100.25.141.132` in your API calls.
