#!/bin/sh
echo 'clear apt cache...'
sudo apt-get -y clean

echo 'apt-get update...'
# -qq : Please be quiet.
sudo apt-get -qq -y update

echo 'installing misc tools...'
sudo apt-get -y install wget unzip jq

echo 'installing pip...'
sudo apt-get -y install python-pip

echo 'installing aws cli...'
sudo pip install awscli --ignore-installed six

echo 'Completed'