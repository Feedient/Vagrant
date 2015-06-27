#!/bin/bash
 
#Force file syncronization and lock writes
#mongo admin --eval "printjson(db.fsyncLock())"

BACKUP_PATH="/var/backups/mongodb"
MONGODUMP_PATH="/usr/bin/mongodump"
MONGO_HOST="127.0.0.1" #replace with your server ip
MONGO_PORT="27017"
MONGO_DATABASES=( "feeds" "metrics" ) #replace with your database name
 
TIMESTAMP=`date +%F-%H%M`
#S3_BUCKET_NAME="bucketname_here" #replace with your bucket name on Amazon S3
#S3_BUCKET_PATH="mongodb-backups"

# Check if backupdir exists, create if not
if ! [ -d $BACKUP_PATH ]
	then
	sudo mkdir -p $BACKUP_PATH
fi
 
# Move CWD
cd $BACKUP_PATH

# Backup all the dbs
for DATABASE in "${MONGO_DATABASES[@]}"
do
    # Create backup
	$MONGODUMP_PATH -h $MONGO_HOST:$MONGO_PORT -d $DATABASE
	 
	# Add timestamp to backup
	mv dump mongodb-$HOSTNAME-$TIMESTAMP
	tar cf mongodb-$HOSTNAME-$DATABASE-$TIMESTAMP.tar mongodb-$HOSTNAME-$TIMESTAMP
	rm -R mongodb-$HOSTNAME-$TIMESTAMP
done
 
# Upload to S3
#s3cmd put mongodb-$HOSTNAME-$TIMESTAMP.tar 
#   s3://$S3_BUCKET_NAME/$S3_BUCKET_PATH/mongodb-$HOSTNAME-$TIMESTAMP.tar
 
#Unlock database writes
#mongo admin --eval "printjson(db.fsyncUnlock())"