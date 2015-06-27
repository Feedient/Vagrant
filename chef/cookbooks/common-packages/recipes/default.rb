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
#
common_packages = ['python-software-properties', 'python', 'g++', 'git-core', 'curl', 'vim', 'nano', 'make', 'python-dev']

common_packages.each do |pkg|
	package pkg do
		:upgrade
	end
end

execute "install easy_install" do
	command "curl -O http://python-distribute.org/distribute_setup.py && sudo python distribute_setup.py"
	cwd "/root"
	user "root"
end