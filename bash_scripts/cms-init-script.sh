#!/bin/bash
#
# chkconfig: - 98 02
# description:

### BEGIN INIT INFO
# Provides: cms
# Required-Start: $local_fs $network $remote_fs
# Required-Stop: $local_fs $network $remote_fs
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: A basic init script to startup cms
# Description: A basic init script to startup cms
### END INIT INFO


#!/bin/sh

# Colors for echo-ing
NO_ECHO_COLOR='\e[0m'
OK_ECHO_COLOR='\e[0;32m'
WARN_ECHO_COLOR='\e[0;33m'
ERROR_ECHO_COLOR='\e[0;31m'

echoOk() { echo -e "${OK_ECHO_COLOR}$1${NO_ECHO_COLOR}"; }
echoWarn() { echo -e "${WARN_ECHO_COLOR}$1${NO_ECHO_COLOR}"; }
echoError() { echo -e "${ERROR_ECHO_COLOR}$1${NO_ECHO_COLOR}"; }

# Setup variables
USER=ubuntu
SERVICE_NAME=cms
PID_FILE="/var/run/${SERVICE_NAME}.pid"

# Sometimes during system startup the open file limit is set very low, causing problems in high traffic high volume servers. Set open file limits to the effective maximum for this service.
ulimit -n 999999

start_server()
{
    PID_FILE_FOR_STARTUP=/tmp/${SERVICE_NAME}.pid.startup

    rm -f $PID_FILE_FOR_STARTUP
    su - $USER -c "/opt/cerberus/start-${SERVICE_NAME}.sh --pid-file $PID_FILE_FOR_STARTUP"

    PID_FROM_STARTUP=$(cat $PID_FILE_FOR_STARTUP)
}

case "$1" in
    start)
        if [ -f $PID_FILE ]; then
            # PID file exists. See if the service is still running (service could have died without the PID file being cleaned up)
            OLD_PID=`cat $PID_FILE`
            if [ -z "`ps axf | grep ${OLD_PID} | grep -v grep`" ]; then
                # No process is running under that PID, so it must have died without the file being cleaned up. Start the service.
                echoWarn "$SERVICE_NAME is not running but the PID file exists. The process probably died unexpectedly. Orphaned PID: [$OLD_PID]"
            else
                # There is a process still running under that PID.
                echoWarn "Already running $SERVICE_NAME under process ID: [$OLD_PID]. Nothing to do."
                exit 0
            fi
        fi

        # No PID file exists (or it exists but the service is not actually running). Start up the service.
        echoOk "Starting $SERVICE_NAME ..."
        start_server

        # See if the server startup was successful
        if [ -z $PID_FROM_STARTUP ]; then
            echoError "PID not found. $SERVICE_NAME probably did not start."
            exit 3
        else
            echo $PID_FROM_STARTUP > $PID_FILE
            echoOk "$SERVICE_NAME successfully started with PID: [$PID_FROM_STARTUP]"
            exit 0
        fi
    ;;
    stop)
        if [ -f $PID_FILE ]; then
            # PID file exists. See if the service is still running (service could have died without the PID file being cleaned up)
            OLD_PID=`cat $PID_FILE`
            if [ -z "`ps axf | grep ${OLD_PID} | grep -v grep`" ]; then
                echoError "$SERVICE_NAME is not running but the PID file exists. The process probably died unexpectedly. Orphaned PID: [$OLD_PID]"
                exit 1
            else
                # Process is still running. Kill it.
                echoOk "Stopping $SERVICE_NAME ..."
                kill -HUP $OLD_PID
                echoOk "$SERVICE_NAME successfully stopped. Old PID: [$OLD_PID]"
                rm -f $PID_FILE
                exit 0
            fi
        else
            echoWarn "$SERVICE_NAME is not running. No PID file found at: $PID_FILE. Nothing to do."
            exit 0
        fi
    ;;
    restart)
        $0 stop
        $0 start
    ;;
    status)
        if [ -f $PID_FILE ]; then
            OLD_PID=`cat $PID_FILE`
            if [ -z "`ps axf | grep ${OLD_PID} | grep -v grep`" ]; then
                echoError "$SERVICE_NAME is not running but the PID file exists. The process probably died unexpectedly. Orphaned PID: [$OLD_PID]"
                exit 1
            else
                echoOk "$SERVICE_NAME is running under PID: [$OLD_PID]"
                exit 0
            fi
        else
            echoError "$SERVICE_NAME is not running - no PID file found."
            exit 3
        fi
    ;;
    *)
        echoError "Usage: $0 {start|stop|restart|status}"
        exit 1
    ;;
esac