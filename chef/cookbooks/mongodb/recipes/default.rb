#
# Cookbook Name:: nginx
# Recipe:: default
#
# Copyright 2013, Feedient
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Add key to keyring
execute "sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10" do 
	user "root"
end

# Add repo
execute "echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/10gen.list" do 
	user "root"
end

# Update package sources
execute "sudo apt-get update" do
	user "root"
end

# Install mongodb
package node['mongodb']['package_name'] do
	:install
end

# Make sure the data dir exists
directory "/var/lib/mongodb" do
	owner node['mongodb']['user']
	group node['mongodb']['group']
	mode 0755
	action :create
end

# Make sure the backup dir exists
directory "/var/backups" do
	owner "root"
	group "root"
	mode 0755
	action :create
end

directory "/var/backups/mongodb" do
	owner node['mongodb']['user']
	group node['mongodb']['group']
	mode 0777
	action :create
end

directory "/opt/scripts" do
	owner "root"
	group "root"
	mode 0755
	action :create
end

# Copy backup files
cookbook_file "/opt/scripts/backup_dbs.sh" do
	source "backup_dbs.sh"
	mode 0755
	owner "root"
	group "root"
end

# Create backup crontab
cron "backup_dbs" do
	day "*"
	hour "1"
	minute "0"
	command "cd /opt/scripts && ./backup_dbs.sh"
	action :create
end

# Create keyfile if set
keyfile = nil
if node['mongodb']['keyfile_contents']
    keyfile = "#{node['mongodb']['dbpath']}/keyfile"
    file keyfile do
        content node['mongodb']['keyfile_contents']
        owner node['mongodb']['user']
        group node['mongodb']['group']
        mode 0600
        action :create
    end
end

# Create configfile
template node['mongodb']['configfile'] do
	source "mongodb.conf.erb"
	cookbook "mongodb"
	variables(
		:local_only => node['mongodb']['local_only'],
		:dbpath => node['mongodb']['dbpath'],
		:logpath => node['mongodb']['logpath'],
		:port => node['mongodb']['port'],
		:journal => node['mongodb']['journal'],
		:auth => node['mongodb']['auth'],
		:keyfile => keyfile,
		:nohttpinterface => node['mongodb']['nohttpinterface'],
		:rest => node['mongodb']['rest'],
		:replicaset => node['mongodb']['replicaset'],
		:fork => platform?("centos", "redhat", "fedora", "amazon"),
		:quiet => node['mongodb']['quiet']
	)
	owner "root"
	group "root"
	mode "0644"
	action :create
end

# Create the service
service node['mongodb']['service_name'] do
  supports :start => true, :stop => true, :restart => true
  action [:start, :enable]
end

# Make sure we got no lock
if File.exist?("/var/lib/mongodb/mongod.lock")
	# Make sure that we do not have a mongo lock
	execute "sudo rm /var/lib/mongodb/mongod.lock" do
    	user "root"
    end

	# Repair, does not needs to be run with journaling
    #execute "sudo mongod --config /etc/mongodb.conf --repair" do
    #	user "root"
    #end

    # Change rights
	execute "sudo chown -R mongodb:nogroup /var/lib/mongodb/" do
    	user "root"
    	notifies :restart, "service[#{node['mongodb']['service_name']}]", :immediately
    end    
end

# install pymongo on staging and production
if node['mongodb']['keyfile_contents'] == 'stag' || node['mongodb']['keyfile_contents'] == 'prod'
	execute "install-pymongo" do
		command "sudo easy_install pymongo"
		user "root"
	end
end
# Load databag + create mongo users
# Roles: http://docs.mongodb.org/manual/reference/user-privileges/#userAdmin
#accounts = data_bag('db_users')
#
# accounts.each do |account_content|
#   	account = data_bag_item('db_users', account_content)

#   	username = account['username']
#   	password = account['password']
#   	roles = account['roles']

#   	# db.getSiblingDB(db_name).addUser(username, password)
# 	bash "insert-user" do
# 		user "root"
# 		code <<-EOH 
# 			mongo --eval 'db.getSiblingDB("admin").addUser({ user: "#{username}", pwd: "#{password}", roles: #{roles} });'
# 			EOH
# 	end
# end

# # Restart mongo
# execute "sudo service mongodb restart" do
# 	user "root"
# end    