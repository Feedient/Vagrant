#!/bin/bash

# Where to download release too
DOWNLOAD_DIR=/var/releases/api.feedient.com

# Where to place sources
TARGET_DIR=/var/www/api.feedient.com

# First, get the zip file
cd $DOWNLOAD_DIR && wget -O production.zip -q https://github.com/thebillkidy/Feedient-Server/archive/production.zip

# Second, unzip it, if the zip file exists
if [ -f $DOWNLOAD_DIR/production.zip ]; then
    # Unzip the zip file
    unzip -q $DOWNLOAD_DIR/production.zip

    # Delete zip file
    rm $DOWNLOAD_DIR/production.zip

    # Delete current directory
    rm -rf $TARGET_DIR

    # Rename project directory to desired name
    mv Feedient-Server-production $TARGET_DIR

    # Clean-up
    rm -rf Feedient-Server-production

    # Perhaps call any other scripts you need to rebuild assets here
    # or set owner/permissions
    # or confirm that the old site was replaced correctly
    cd $TARGET_DIR && sudo npm install && sudo supervisorctl restart api_server
fi