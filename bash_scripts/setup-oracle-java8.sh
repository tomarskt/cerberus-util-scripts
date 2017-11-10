#!/bin/bash

# Download Oracle Java 8 accepting the license
wget --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" \
http://download.oracle.com/otn-pub/java/jdk/8u152-b16/aa0333dd3019491ca4f6ddbe78cdb6d0/server-jre-8u152-linux-x64.tar.gz

if [ ! -f server-jre-*.tar.gz ]
then 
  echo "Failed to download Server JRE"
  exit 1
fi

# Extract the archive
tar -xzvf server-jre-*.tar.gz
# clean up the tar
rm -fr server-jre-8u112-linux-x64.tar.gz
# mk the jvm dir
sudo mkdir -p /usr/lib/jvm
# move the server jre
sudo mv jdk1.8* /usr/lib/jvm/oracle_jdk8

# install unlimited strength policy
wget -q --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" \
http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip

if [ ! -f jce_policy-8.zip ]
then 
  echo "Failed to download Unlimited Strength Policy Jar"
  exit 1
fi

unzip jce_policy-8.zip
mv UnlimitedJCEPolicyJDK8/local_policy.jar /usr/lib/jvm/oracle_jdk8/jre/lib/security/
mv UnlimitedJCEPolicyJDK8/US_export_policy.jar /usr/lib/jvm/oracle_jdk8/jre/lib/security/

sudo update-alternatives --install /usr/bin/java java /usr/lib/jvm/oracle_jdk8/jre/bin/java 2000
sudo update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/oracle_jdk8/bin/javac 2000

sudo update-alternatives --auto java
sudo update-alternatives --auto javac

sudo echo "export J2SDKDIR=/usr/lib/jvm/oracle_jdk8
export J2REDIR=/usr/lib/jvm/oracle_jdk8/jre
export PATH=$PATH:/usr/lib/jvm/oracle_jdk8/bin:/usr/lib/jvm/oracle_jdk8/db/bin:/usr/lib/jvm/oracle_jdk8/jre/bin
export JAVA_HOME=/usr/lib/jvm/oracle_jdk8
export DERBY_HOME=/usr/lib/jvm/oracle_jdk8/db" | sudo tee -a /etc/profile.d/oraclejdk.sh
