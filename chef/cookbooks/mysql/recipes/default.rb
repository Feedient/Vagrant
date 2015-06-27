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
mysql_packages = ['mysql-server', 'mysql-client', 'mysql-common']

mysql_packages.each do |pkg|
	package pkg do
		:upgrade
	end
end

# Service
service  "mysql" do
	enabled true
	running true
	supports :status => true, :restart => true
	action [:start, :enable]
end

# Files
cookbook_file "/etc/mysql/my.cnf" do
	source "my.cnf"
	mode 0640
	owner "root"
	group "root"
	notifies :restart, resources(:service => "mysql")
end

# Commands
#execute "mysql-grant-outside-vagrant" do
#	command "mysql -uroot -p#{node['mysql']['server_root_password']} -e \"GRANT ALL ON *.* TO '#{node['mysql']['server_user']}'@'%' IDENTIFIED BY '#{node['mysql']['server_pass']}';\""
#end