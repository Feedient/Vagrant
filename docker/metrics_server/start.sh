#!/bin/bash

# Run tiller
/usr/local/bin/tiller

# Create dir supervisor if it doesn't exist
if [ ! -d "/var/log/supervisor" ]; then
    echo "Creating /var/log/supervisor directory"
    mkdir -p /var/log/supervisor
fi

# Start supervisord
/usr/bin/supervisord -c /etc/supervisor/supervisord.conf
