# To use: 
# ssh root@hostname 'wget http://mentalized.net/files/servers/development_node.sh && bash development_node.sh'

# Exit if an error occurs
set -e

# Basic setup
hostname alexander.substancelab.com
apt-get update
apt-get -y dist-upgrade
apt-get -y install build-essential
apt-get update

# Get the time right
apt-get -y install ntp ntpdate
echo "UTC timezone is found under '12: None of the Above'"
tzconfig

# Tools and utilities
apt-get -y install git-core subversion apticron rsync

# Databases
apt-get -y install postgresql-8.1

# Apache
apt-get -y install apache2 apache2-prefork-dev

# Ruby
apt-get -y install ruby libzlib-ruby rdoc irb rubygems librexml-ruby ruby1.8-dev

# Update gems
gem update --system
rm /usr/bin/gem
ln -s /usr/bin/gem1.8 /usr/bin/gem

# Gems
gem install rake rails postgres 

# Passenger
gem install fastthread passenger --platform ruby
passenger-install-apache2-module
echo "
LoadModule passenger_module /usr/lib/ruby/gems/1.8/gems/passenger-2.0.3/ext/apache2/mod_passenger.so
PassengerRoot /usr/lib/ruby/gems/1.8/gems/passenger-2.0.3
PassengerRuby /usr/bin/ruby
" > /etc/apache2/mods-available/passenger.load
a2enmod passenger
apache2ctl restart

# User
adduser koppen
addgroup substancelab
addgroup koppen substancelab

# Add user as sudoer
apt-get install sudo
echo "koppen   ALL=(ALL) ALL" >> /etc/sudoers
visudo -c

# Add user to PostgreSQL as well
su postgres -c "createuser --superuser koppen"

