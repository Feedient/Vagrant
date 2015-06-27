#
# Cookbook Name:: Feedient-Metrics
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

# Clone metrics to the optional software dir
execute "git clone git://github.com/Feedient/Metrics.git feedient-metrics" do
	cwd "/opt"
	user "root"
	not_if { File.exist?("/opt/feedient-metrics") }
end

execute "sudo npm install" do
	cwd "/opt/feedient-metrics"
	user "root"
end

# Add conf files + startup file
template "config.js" do
	path "/opt/feedient-metrics/config.js"
	source "config.js.erb"
	owner "root"
	group "root"
	mode "0644"
end

#############
# SUPERVISOR
#############
# Install it into supervisor
cookbook_file "/etc/supervisor/conf.d/statsd.conf" do
	source "supervisor_metrics.conf"
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