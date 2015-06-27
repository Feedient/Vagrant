# Installation
## Installation Steps
### Staging
#### Mac Prerequisites
* Virtualbox (Get the latest version here: https://www.virtualbox.org/wiki/Downloads)
* Vagrant (Get the latest version here: http://downloads.vagrantup.com/)
* Git
* XCode
* XCode Command-Line Tools

#### Windows Prerequisites
* Virtualbox (Get the latest version here: https://www.virtualbox.org/wiki/Downloads)
* Vagrant (Get the latest version here: http://downloads.vagrantup.com/)
* Git

#### Installation
1. Clone this repository using `git clone https://github.com/thebillkidy/Feedient-Vagrant.git`
2. Open a terminal and navigate to the directory
3.	__(Windows only)__
	1. If you're on Windows, run `dos2unix install.sh` and `dos2unix chef.rb`
	2. Go to the VagrantFile and comment out the line that has `:nfs => true` on the end and uncomment the second line that doesn't have that.
4. Enter `vagrant plugin install vagrant-vbguest` (This will upgrade the guest addition when needed)
5. Enter `vagrant up <sitename>` (example: `vagrant up local.feedient.com` for the development box)
6. Wait till it is completely done (Go grab some food or a drink :D)
7. When it is done press `vagrant ssh <sitename>` (example: `vagrant ssh local.feedient.com` for the vagrant box) to enter the terminal
8. When on the box make sure to run `sudo service nginx restart` if you can not access the webserver
9. Make sure to run post installation steps, example: symfony2 needs the composer to 	update the vendors, ...
10. Have fun using Vagrant :D

### Production
#### Prerequisites
* Git (`apt-get -y install git-core`)

#### Installation
1. Login on your production server (ssh) and open a terminal
2. Clone this repository using `git clone https://github.com/thebillkidy/Feedient-Vagrant.git`
3. run `./install.sh <sitename>` (Example: `./install.sh feedient.com`), this will check if chef is installed and will install if if needed, it will also run for your defined configuration.
4. Wait till it is completely done (Go grab some food or a drink :D)
5. When it is done run your post installation steps, example: symfony2 needs composer to update the vendors, ...
6. Have fun using your new server

#### Used cookbooks from remote repositories:
	https://github.com/opscode-cookbooks/java (Stripped windows support)

## Git webhooks
https://github.com/thebillkidy/Feedient-Client/settings/hooks : http://test.feedient.com:9001
https://github.com/thebillkidy/Feedient-Server/settings/hooks : http://test.feedient.com:9002

## FAQ
### Vagrant
__(When booting i get a error saying that the guest machine entered an invalid state while waiting for it to boot.)__
This is a virtualbox error, make sure that you disable Enable `VT-x/AMD-V` in <machine> --> Settings --> System --> Acceleration

## Misc
### Interesting Vagrant Commands
* `vagrant halt <sitename>` (Stops the vagrant box)
* `vagrant reload <sitename>` (Restarts the vagrant box)
* `vagrant provision <sitename>` (Runs the provisioner for vagrant again)

### Checking running programs in supervisor
We use supervisor to keep the node applications running, they will also automatically restart and output logs to /var/log
to check this programs you can do: `supervisorctl` in the command line, this will open a shell where we can do commands such as:
`supervisor> help`
`supervisor> stop program_name`
`supervisor> start program_name`

If you changed the supervisor programs.conf in /etc/supervisor/conf.d/programs.conf then you have to reload:
`sudo supervisorctl reread` and `sudo supervisorctl update`

### Backup mongo
Mongo backups are taken every day, they are saved in /var/backups/mongodb

### Connect mms agent
1. Go to mms.mongodb.com
2. Get the monitoring agent.zip and unzip
3. Inside that dir run: `nohup python agent.py >> /var/log/agent.log 2>&1 &`

### Add mongodb user
* http://docs.mongodb.org/manual/reference/method/db.addUser/
* http://docs.mongodb.org/manual/reference/built-in-roles/#built-in-roles

#### Create user on Admin db
* use admin;
* db.createUser({ user: "admin", pwd: "idT7XBVgAhHkF6y", roles: [ "root" ]});

#### Create user on Feeds db
* use feeds;
* db.createUser({ user: "admin", pwd: "idT7XBVgAhHkF6y", roles: [{ role: "readWrite", db: "feeds" }]});

#### Create user on Metrics db
* use metrics;
* db.createUser({ user: "admin", pwd: "idT7XBVgAhHkF6y", roles: [{ role: "readWrite", db: "metrics" }]});

### Auth as mongo user
1. use admin;
2. db.auth("admin", "idT7XBVgAhHkF6y");

### Remove user
1. use admin;
2. db.removeUser("admin")
3. db.removeUser("admin")
