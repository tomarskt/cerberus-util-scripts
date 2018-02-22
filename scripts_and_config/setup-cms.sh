#!/bin/sh

mv_temp_file() {
    FROM=$1
    TO=$2
    USER=$3
    GROUP=$4
    PERM=$5

    sudo mv ${FROM} ${TO}
    sudo chown ${USER}:${GROUP} ${TO}
    sudo chmod ${PERM} ${TO}
}

create_dir() {
    DIR=$1
    USER=$2
    GROUP=$3
    PERM=$4

    sudo mkdir ${DIR}
    sudo chown ${USER}:${GROUP} ${DIR}
    sudo chmod ${PERM} /opt/cerberus
}

# move and setup ec2 user data service
mv_temp_file /tmp/ec2_user_data.conf /etc/init/ec2_user_data.conf root root 0644

# Make sure we have the /opt/cerberus directory for placing the server artifacts/scripts in a known location.
create_dir /opt/cerberus ubuntu ubuntu 755

# Create the directory where the log files will go.
create_dir /var/log/cms ubuntu ubuntu 755

# Copy the init script to its final location.
mv_temp_file /tmp/cms-init-script.sh /etc/init.d/cms root root 755

# Copy the server startup script to its final location (the init script calls this).
mv_temp_file /tmp/start-jar-script.sh /opt/cerberus/start-cms.sh ubuntu ubuntu 755

# Copy the default JVM behavior args script to its final location (the server startup script sources this to get default
# JVM behavior args like heap memory size, garbage collection tweaks, etc).
mv_temp_file /tmp/jvm-behavior-args.sh /etc/default/jvm-behavior-args ubuntu ubuntu 0644

# Copy the server jar to its final location.
mv_temp_file /tmp/cms.jar /opt/cerberus/cms.jar ubuntu ubuntu 755

# move the cloud formation signal sender service
mv_temp_file /tmp/cms_signal.conf /etc/init/cms_signal.conf root root 0644

# move the log rotate file
mv_temp_file /tmp/log_rotate /etc/logrotate.d/cms root root 755

# make cms autostart at boot
sudo update-rc.d cms defaults