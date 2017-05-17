#!/bin/sh
echo 'clear apt cache...'
sudo apt-get -y clean

#add any new source lists
echo 'Adding puppet sources to apt'
wget https://apt.puppetlabs.com/puppetlabs-release-`lsb_release -sc`.deb
sudo dpkg -i puppetlabs-release-`lsb_release -sc`.deb

echo 'apt-get update...'
# -qq : Please be quiet.
sudo apt-get -qq -y update

echo 'installing build tools...'
sudo apt-get -y install git build-essential ruby-dev wget lsb-release unzip

echo 'installing puppet and its tools...'
sudo apt-get -y install puppet hiera facter ruby-highline ruby-thor
# trusty librarian-puppet to old, use gem
sudo gem install --no-rdoc --no-ri bundler
sudo gem install --no-rdoc --no-ri librarian-puppet

echo 'installing pip...'
sudo apt-get -y install python-pip
echo 'installing aws cli...'
sudo pip install awscli --ignore-installed six

echo 'Completed'