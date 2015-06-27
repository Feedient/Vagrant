#!/bin/bash

# Run tiller
/usr/local/bin/tiller > /dev/null 2>&1

# Start grunt watcher in background
cd /var/www/feedient.com
npm install
grunt default > /dev/null 2>&1 &

# Start Nginx (Main process)
/usr/sbin/nginx
