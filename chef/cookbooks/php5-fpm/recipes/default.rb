#
# Cookbook Name:: php5-fpm
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

php_packages = ['php5', 'php-apc', 'php5-fpm', 'php5-curl', 'php5-cli', 'php5-intl', 'php5-imagick', 'php5-imap', 'php5-mcrypt', 'php5-memcached', 'php5-ming', 'php5-mysql', 'php5-pspell', 'php5-recode', 'php5-snmp', 'php5-tidy', 'php5-xmlrpc', 'php5-xsl', 'php5-xcache']

# Packages
php_packages.each do |pkg|
	package pkg do
		:upgrade
	end
end

# Service
service "php5-fpm" do
	enabled true
	running true
	supports :status => true, :restart => true, :reload => true
	action [:start, :enable]
end

# Files
cookbook_file "/etc/php5/fpm/pool.d/www.conf" do
	source "www.conf"
	mode 0640
	owner "root"
	group "root"
	notifies :restart, resources(:service => "php5-fpm")
end

cookbook_file "/etc/php5/cli/php.ini" do
	source "php_cli.ini"
	mode 0640
	owner "root"
	group "root"
	notifies :restart, resources(:service => "php5-fpm")
end

cookbook_file "/etc/php5/fpm/php.ini" do
	source "php_fpm.ini"
	mode 0640
	owner "root"
	group "root"
	notifies :restart, resources(:service => "php5-fpm")
end

cookbook_file "/etc/php5/conf.d/apc.ini" do
	source "apc.ini"
	mode 0640
	owner "root"
	group "root"
	notifies :restart, resources(:service => "php5-fpm")
end

cookbook_file "/etc/php5/conf.d/memcached.ini" do
	source "memcached.ini"
	mode 0640
	owner "root"
	group "root"
	notifies :restart, resources(:service => "php5-fpm")
end
