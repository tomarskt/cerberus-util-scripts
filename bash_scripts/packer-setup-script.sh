#!/bin/sh

echo 'clear apt cache...'
sudo apt-get -y clean

echo 'apt-get update and upgrade...'
sudo apt-get -y update
sudo apt-get -y upgrade

echo 'installing build tools...'
sudo apt-get -y install git build-essential ruby-dev wget lsb-release

echo 'installing puppet...'
wget https://apt.puppetlabs.com/puppetlabs-release-`lsb_release -sc`.deb
sudo dpkg -i puppetlabs-release-`lsb_release -sc`.deb
sudo apt-get -y update
sudo apt-get -y install puppet hiera facter ruby-highline ruby-thor

echo 'installing pip'
sudo apt-get -y install python-pip

echo 'installing aws cli'
sudo pip install awscli --ignore-installed six

# trusty librarian-puppet to old, use gem
sudo gem install --no-rdoc --no-ri bundler
sudo gem install --no-rdoc --no-ri json -v 1.8.3
sudo gem install --no-rdoc --no-ri librarian-puppet -v 1.0.3