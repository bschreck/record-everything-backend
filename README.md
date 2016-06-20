backend for data collection app


# Running Locally
Checkout server.js, it contains a command processing utility that allows
us to run `node server.js startlocal` in order to start the application
locally. It will run on 8080

# Running On AWS
Do a git commit and push, and then log into the AWS server. I configured
the `.bash_profile` on the remote server to automatically start
ssh-agent when I log in so that I don't need to enter a password every
time I run git pull (see
http://mah.everybody.org/docs/ssh#run-ssh-agent). This allowed me to create a bash script for
grabbing code from git and restarting the app. It's located at
`pull_and_restart.sh`
