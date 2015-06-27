#!/bin/bash
#============================================================
#          FILE:  install.sh
#         USAGE:  ./install.sh sitename
#   DESCRIPTION: This script will install the site with the given configuration
#
#       OPTIONS:  $1 The Imagename for the installed DockerContainer
#       OPTIONS:  $2 The name to call it after installation
#       OPTIONS:  $3 The Ports to be forwarded afterwards
#       OPTIONS:  $4 Environment variable
#       OPTIONS:  $5 Start Shell?
#       OPTIONS:  $6 Which dir do we require before starting?
#       OPTIONS:  $7 Shared Directory
#
#  REQUIREMENTS:  /
#        AUTHOR:  Xavier Geerinck (thebillkidy@gmail.com)
#       COMPANY:  Feedient
#       VERSION:  1.2.0
#       CREATED:  18/08/13 20:12:38 CET
#      REVISION:  ---
#============================================================
# sudo sh install.sh test_api_server 8002:8002 staging false '/var/www/test.api.feedient.com' '/var/www:/var/www -v /var/log/feedient/api_server:/var/log'
# Config parameters
docker_binary=/usr/bin/docker

# Check parameters (We need the dockerpath too install + name for the image)
if [ -z "$1" -o -z "$2" -o -z "$3" -o -z "$4" -o -z "$5" -o -z "$6" ]; then
    echo "Usage: `basename $0` <ImageName> <ContainerName> <BootName> <PortForwards> <Environment> <StartShell> <RequireDir>"
	echo "Example: `basename $0` ghost_demo 60000:2307 development false /var/www"
	echo "Info: The DockerfilePath is the path from this as root to the directory where the Dockerfile is located"

	exit 0
fi

# If chef is not installed then install it
echo "Checking if Docker is installed..."
if ! test -f "$docker_binary"; then
	echo "Downloading and installing docker"

    # Update binaries
	sudo apt-get update

	# Install wget & ca-certificates
	sudo apt-get install -y wget ca-certificates docker.io

	# Link and fix paths
	ln -sf /usr/bin/docker.io /usr/local/bin/docker
    sed -i '$acomplete -F _docker docker' /etc/bash_completion.d/docker.io

    # Start Docker on server boot
    update-rc.d docker.io defaults
else
	echo "Docker is already installed"
fi

echo "Running docker"
cd ./docker/$1 && \
echo "Building the docker image from the dockerfile located at: /home/core/share/docker/"$1 && \
docker build -t "$1" .

# Build docker command
cmd="docker run --name $2 -t -d -i"

# Append ports
if [ ! -z "$3" -a "$3" != "false" ];
    then
    cmd+="-p $3"
fi

# Append environment if set (production default)
if [ ! -z "${4// /}" ];
    then
    cmd+=" -e environment=$4"
fi

# Append shared dir if set
if [ ! -z "${7// /}" ];
    then
    cmd+=" -v $7"
fi

# Append the image name as last
cmd+=" $1"

# Append shared dir if set
if [ ! $5 == "false" ];
    then
    cmd+=" /bin/bash"
fi

# Run docker cmd
echo "Running the command: $cmd"
echo "Starting up the docker container: $1"
$cmd

# Check if dir exists
if [ ! -d "/etc/systemd/system/multi-user.target.wants" ]; then
    echo "Creating /etc/systemd/system/multi-user.target.wants directory"
    mkdir /etc/systemd/system/multi-user.target.wants
fi

# Create a systemd script that will start the container on boot, wait 10 secs so vagrant can sync dirs
echo "Installing the /etc/systemd/system/$1.service script"

startCommand="/usr/bin/$cmd"

# If we require a directory to be mounted before starting, read the start command script into it's variable
if [ ! -z "$6" -a "$6" != "false" ]; then
read -d '' startCommand << EOF
/bin/sh -c '
    while : ;
    do
        [[ -d "$6" ]] && break;
        echo "Waiting till directory is mounted";
        sleep 1;
    done;

    /usr/bin/$cmd;
'
EOF
fi

# Install the service (This removes the old container and then starts it)
# Remove docker containers of type: /bin/sh -c 'docker ps -a | grep "$1" | awk '\''{print \$1}'\'' | xargs docker rm;' && `echo $startCommand`
# Note: - is because it can fail, but we should still continue
cat > /etc/systemd/system/multi-user.target.wants/$1.1.service << EOF
[Unit]
Description=$1
Requires=docker.service
After=docker.service

[Service]
TimeoutStartSec=0
KillMode=none
ExecStartPre=-/usr/bin/docker kill $1
ExecStartPre=-/usr/bin/docker rm $1
ExecStart=`echo $startCommand`
ExecStopPre=/usr/bin/docker stop $1
ExecStop=-/usr/bin/docker rm $1

[Install]
WantedBy=multi-user.target

[X-Fleet]
X-Conflicts=$1.*.service
EOF


# Reload the systemctl daemon
echo "Reloading systemctl daemon"
systemctl daemon-reload

echo "Done"
exit 0
