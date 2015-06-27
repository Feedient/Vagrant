# Pull base image.
FROM dockerfile/ubuntu

# ###############################
#        NODEJS & NPM SETUP
# https://github.com/dockerfile/nodejs
# ###############################

RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get clean
RUN apt-get update
RUN apt-get -y install python-software-properties git build-essential
RUN add-apt-repository -y ppa:chris-lea/node.js
RUN apt-get update
RUN apt-get -y install nodejs

# ###############################
#          NGINX SETUP
# https://github.com/dockerfile/nginx
# ###############################

# Install Nginx.
RUN \
  apt-get clean && \
  add-apt-repository -y ppa:nginx/stable && \
  apt-get update && \
  apt-get install -y nginx && \
  rm -rf /var/lib/apt/lists/* && \
  chown -R www-data:www-data /var/lib/nginx

# ###############################
#          RUBY INSTALL
# ###############################

# Install Ruby 1.9.1
RUN \
  apt-get clean && \
  apt-get update && \
  apt-get install -y ruby1.9.1 ruby1.9.1-dev build-essential make automake autoconf wget ssl-cert curl

# ###############################
#   INSTALL OWN NGINX CONFIGS
# ###############################

# Remove the default Nginx configuration file
RUN rm -v /etc/nginx/nginx.conf

# Define mountable directories.
VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/conf.d", "/var/log/nginx"]

# ###############################
# Feedient Specific Configuration
# ###############################

# Install Tiller (Configuration management)
RUN gem1.9.1 install tiller

# Copy over the tiller dir with our environment configuration
ADD data/tiller /etc/tiller

# Install the libraries (npm install) (We copy over the package.json already)
RUN \
  apt-get clean && \
  mkdir -p /var/www/feedient.com && \
  npm install -g grunt-cli

# Install boot script
ADD start.sh /start.sh
RUN chmod 755 /start.sh

# On development run grunt
CMD ["/start.sh"]

# Expose ports.
EXPOSE 80
EXPOSE 443
