#!/bin/bash
#============================================================
#          FILE:  install.sh
#         USAGE:  ./install.sh sitename
#   DESCRIPTION: This script will install the site with the given configuration
#
#       OPTIONS:  $2 dirname to look after the scripts
#  REQUIREMENTS:  /
#        AUTHOR:  Xavier Geerinck (thebillkidy@gmail.com)
#       COMPANY:  Feedient
#       VERSION:  1.1.0
#       CREATED:  18/08/13 20:12:38 CET
#      REVISION:  ---
#============================================================
# Config parameters
chef_binary=/usr/local/bin/chef-solo

# Check parameters
if [ -z "$1" ]; then
	echo "Usage: `basename $0` sitename"
	echo "Example: `basename $0` prod_feedient.com"
	echo "Info: sitename is defined in sites/sitename.json"

	exit 0
fi

# If stupid apache is installed, then remove it
if type -p apache2.2-bin > /dev/null; then
	echo "Removing Apache2"

	sudo apt-get remove -y apache2.2-bin
	sudo apt-get autoremove
fi

# If chef is not installed then install it
echo "Checking Chef..."
if ! test -f "$chef_binary"; then
	echo "Downloading and installing chef"

	sudo apt-get update 
	
	# Remove ruby 1.8
	sudo apt-get --purge remove ruby ruby1.8 rubygems libruby libruby1.8 ruby-rvm ruby1.8-dev

	# Install ruby 1.9
	sudo apt-get install -y \
	ruby1.9.1 ruby1.9.1-dev build-essential \
	make automake autoconf wget ssl-cert curl

	# Install chef, no docs
	sudo gem1.9.1 install --no-rdoc --no-ri chef

    # Install capistrano
    sudo gem install --no-rdoc --no-ri capistrano
else 
	echo "Chef already installed"
fi

echo "Running chef for the specified configuration"
chef-solo -c $2chef.rb -j $2sites/$1.json

echo "Done"
exit 0
