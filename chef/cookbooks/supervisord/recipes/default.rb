#
# Cookbook Name:: Supervisord
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

package "supervisor" do
	:upgrade
end

# Add conf files + startup file
cookbook_file "/etc/supervisor/supervisord.conf" do
	source "supervisord.conf"
	mode 0644
	owner "root"
	group "root"
end

cookbook_file "/etc/init.d/supervisord" do
	source "supervisord_initd.sh"
	mode 0775
	owner "root"
	group "root"
end

template "programs.conf" do
	path "/etc/supervisor/conf.d/programs.conf"
	source "programs.conf.erb"
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

# Start supervisor on boot
execute "sudo update-rc.d supervisord defaults" do
	user "root"
end

# Allow user deploy to run sudo supervisor
# We make sure to only add the line once by the use of a if statement
bash "add-deploy-sudo" do
	user "root"
	code <<-EOH
	if ! grep -Fxq "deploy ALL=(root) NOPASSWD:/usr/bin/supervisorctl restart api_server" /etc/sudoers
	then
		sudo echo 'deploy ALL=(root) NOPASSWD:/usr/bin/supervisorctl restart api_server' >> /etc/sudoers
	fi
	EOH
end

# Enable the service
service  "supervisor" do
	enabled true
	running true
	supports :status => true, :restart => true
	action [ :enable, :start ]
end

