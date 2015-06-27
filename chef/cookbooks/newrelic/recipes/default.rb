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
execute "install-apt-sources" do 
	user "root"
    command "sudo echo deb http://apt.newrelic.com/debian/ newrelic non-free >> /etc/apt/sources.list.d/newrelic.list && sudo wget -O- https://download.newrelic.com/548C16BF.gpg | apt-key add -"
    not_if { ::File.exists?("/etc/apt/sources.list.d/newrelic.list")}
end

execute "sudo apt-get update" do
	user "root"
end

package "newrelic-sysmond" do
	:upgrade
end

execute "set-license" do
    user "root"
    command "sudo nrsysmond-config --set license_key=#{node['newrelic']['license_key']}"
end

execute "sudo service newrelic-sysmond start" do
    user "root"
end