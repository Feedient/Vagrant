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
execute "sudo add-apt-repository ppa:chris-lea/node.js" do 
	user "root"
end

execute "sudo apt-get update" do
	user "root"
end

package "nodejs" do
	:upgrade
end

execute "sudo npm install -g grunt-cli" do
    user "root"
end