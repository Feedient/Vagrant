#!/bin/bash

# Where to download release too
DOWNLOAD_DIR=/var/releases/feedient.com

# Where to place sources
TARGET_DIR=/var/www/feedient.com

# First, get the zip file
cd $DOWNLOAD_DIR && wget -O production.zip -q https://github.com/thebillkidy/Feedient-Client/archive/production.zip

# Second, unzip it, if the zip file exists
if [ -f $DOWNLOAD_DIR/production.zip ]; then
    # Unzip the zip file
    unzip -q $DOWNLOAD_DIR/production.zip

    # Delete zip file
    rm $DOWNLOAD_DIR/production.zip

    # Delete current directory
    rm -rf $TARGET_DIR

    # Rename project directory to desired name
    mv Feedient-Client-production $TARGET_DIR

    # Clean-up
    rm -rf Feedient-Client-production

    # Perhaps call any other scripts you need to rebuild assets here
    # or set owner/permissions
    # or confirm that the old site was replaced correctly
    cd $TARGET_DIR && ssg . 
fi