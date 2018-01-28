#!/bin/bash

print_usage()
{
        echo "USAGE: /path/to/script.sh --pid-file /path/to/pidfile.pid"
        echo "   --pid-file = The path to the file this script should use to output the PID of the process it starts up. If this file already exists then it will be overwritten."
}

# Validate the args - we expect to be told where to write a PID file
if [ "$1" != "--pid-file" ]
then
        echo "First arg token was not --pid-file"
        print_usage
        exit 1
fi

if [ -z "$2" ]
then
        echo "Second arg token not found"
        print_usage
        exit 1
fi

PID_FILE_TO_OUTPUT=$2

# Load up environment variables from files that may contain values we need
if [ -f /etc/sysconfig/cms_environment ]
then
        . /etc/sysconfig/cms_environment
fi

if [ -f /etc/default/ec2-user-data ]
then
        . /etc/default/ec2-user-data
fi

CMS=cms

# The app-specific source script must come before the jvm-behavior-args source script to allow for app-specific JVM behavior overrides
if [ -f /etc/default/${CMS} ]
then
        . /etc/default/${CMS}
fi

if [ -f /etc/default/jvm-behavior-args ]
then
        . /etc/default/jvm-behavior-args
fi

# The source script to allow for extra JVM behavior parameters in JVM_CUSTOM_ARGS
if [ -f /etc/default/jvm-custom-args ]
then
        . /etc/default/jvm-custom-args
fi

# Generate the app ID/environment/eureka stuff
# If the CLOUD_DEV_PHASE environment variable exists then that needs to be used for the environment value, otherwise CLOUD_ENVIRONMENT should be used.
# This is here to support perf environment clusters when using Asgard.
export APP_ENVIRONMENT_ARGS="-D@appId=${CMS} \
-Darchaius.deployment.applicationId=${CMS} \
-D@environment=${CLOUD_ENVIRONMENT} \
-Darchaius.deployment.environment=${CLOUD_ENVIRONMENT} \
-Darchaius.deployment.datacenter=cloud \
-Darchaius.deployment.stack=${CLOUD_STACK} \
-D@region=${EC2_REGION}"

# Configure where the stdout/stderr logs should go
LOG_DIR=/var/log/${CMS}
LOG_OUT=$LOG_DIR/client.out
LOG_ERR=$LOG_DIR/client.err

# Allow JVM to access hostname
export HOSTNAME=$(echo $HOSTNAME)

# Start up the service and output the PID to the desired PID file location
java -jar \
${JVM_BEHAVIOR_ARGS} \
${APP_ENVIRONMENT_ARGS} \
${JVM_CUSTOM_ARGS} \
/opt/cerberus/${CMS}.jar > $LOG_OUT 2> $LOG_ERR & echo $! > $PID_FILE_TO_OUTPUT
