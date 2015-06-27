#
# Cookbook Name:: Statsd
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
execute "sudo apt-get update" do
	user "root"
end

package "python-software-properties" do
	:upgrade
end

package "unzip" do
	:upgrade
end

# Make sure the data dir exists
directory "/opt/git_hooks" do
	owner "www-data"
	group "www-data"
	mode 0755
	action :create
end

directory "/var/releases" do
	owner "www-data"
	group "www-data"
	mode 0755
	action :create
end

directory "/var/releases/feedient.com" do
	owner "www-data"
	group "www-data"
	mode 0755
	action :create
end

directory "/var/releases/api.feedient.com" do
	owner "www-data"
	group "www-data"
	mode 0755
	action :create
end

execute "install-gith" do
	command "sudo npm install gith"
	cwd "/opt/git_hooks"
	user "root"
end

execute "install-ssg" do
	command "sudo npm install -g ssg"
	user "root"
end

cookbook_file "/opt/git_hooks/deploy_client.js" do
	source "git_hook_deploy_client.js"
	owner "www-data"
	group "www-data"
	mode "0644"
end

cookbook_file "/opt/git_hooks/deploy_server.js" do
	source "git_hook_deploy_server.js"
	owner "www-data"
	group "www-data"
	mode "0644"
end

cookbook_file "/opt/git_hooks/deploy_client.sh" do
	source "deploy_client.sh"
	owner "www-data"
	group "www-data"
	mode "0644"
end

cookbook_file "/opt/git_hooks/deploy_server.sh" do
	source "deploy_client.sh"
	owner "www-data"
	group "www-data"
	mode "0644"
end

#############
# SUPERVISOR
#############
# Install it into supervisor
cookbook_file "/etc/supervisor/conf.d/git_hook.conf" do
	source "supervisord_git_hook.conf"
	owner "root"
	group "root"
	mode "0644"
end

# Notify supervisor that we installed the files
execute "sudo supervisorctl reread" do
	user "root"
end

execute "sudo supervisorctl update" do
	user "root"
end