# Pull base image.
FROM dockerfile/ubuntu

# ###############################
#        NODEJS & NPM SETUP
# https://github.com/dockerfile/nodejs
# ###############################

#RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get clean
RUN add-apt-repository -y ppa:chris-lea/node.js
RUN apt-get update
RUN apt-get -y install python-software-properties git build-essential libssl-dev
RUN apt-get -y install nodejs

# ###############################
#          RUBY INSTALL
# ###############################

# Install Ruby 1.9.1
RUN apt-get install -y ruby1.9.1 ruby1.9.1-dev build-essential make automake autoconf wget ssl-cert curl

# ###############################
#      SUPERVISOR INSTALL
# ###############################

RUN apt-get update && apt-get install -y supervisor
RUN mkdir -p /var/log/supervisor

# ###############################
# Feedient Specific Configuration
# ###############################

# Install Tiller (Configuration management)
RUN gem1.9.1 install tiller

# Copy over the tiller dir with our environment configuration
ADD data/tiller /etc/tiller

# Install nodemon
RUN npm install -g forever

# Install the libraries (npm install) (We copy over the package.json already)
RUN \
  apt-get clean && \
  mkdir -p /var/www/api.feedient.com && \
  npm install > /dev/null 2>&1 &

# Install boot script
ADD start.sh /start.sh
RUN chmod 755 /start.sh

# On development run grunt
CMD ["/start.sh"]

# Expose ports.
EXPOSE 80
EXPOSE 443
