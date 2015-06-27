default['mongodb']['local_only'] = true
default['mongodb']['environment'] = 'prod'

default['mongodb']['version'] = nil # when set to nil, most recent stable version

default['mongodb']['port'] = 27017
default['mongodb']['journal'] = true
default['mongodb']['rest'] = false
default['mongodb']['nohttpinterface'] = false
default['mongodb']['replicaset'] = nil
default['mongodb']['quiet'] = true

default['mongodb']['configfile'] = "/etc/mongodb.conf"
default['mongodb']['dbpath'] = "/var/lib/mongodb"
default['mongodb']['logpath'] = "/var/log/mongodb/mongodb.log"
default['mongodb']['user'] = "mongodb"
default['mongodb']['group'] = "mongodb"

default['mongodb']['package_name'] = "mongodb-org"
default['mongodb']['service_name'] = "mongod"

default['mongodb']['auth'] = true

# If set, the keyfile will be created in "${dbpath}/keyfile".
# This is necessary only when using authentication with a
# replica set (and will imply node['mongodb']['auth'] = true,
# even if you do not explicitly set it)
# Created by running `openssl rand -base64 258 > mongokey`
default['mongodb']['keyfile_contents'] = nil