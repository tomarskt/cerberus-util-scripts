#!/bin/bash

# This script calculates reasonable defaults for a java-based server when that server is the only real work that the machine needs to do.
# You can override the various bits by making sure a same-named environment variable exists prior to sourcing this script

if [ -z "$JVM_MEMORY_ARGS" ]
then
    MEM_TOTAL_KB=`grep MemTotal /proc/meminfo  | awk '{print $2}'`
    # NOTE: We have to carve out very large chunks of RAM for the OS, because if we don't the overcommitment memory model used in linux might
    #       cause your java app to be squashed by the linux OOM killer even when the java app is perfectly well behaved.
    #       See http://www.oracle.com/technetwork/articles/servers-storage-dev/oom-killer-1911807.html for more info on the topic.
    #       If your java app dies unexpectedly you can execute this command to see if it was the linux OOM killer that caused it: dmesg | egrep -i 'killed process'
    #
    #       Also keep in mind that this is black box guess-and-check magic trying to get these numbers right and reproducing the issue is non-deterministically
    #       difficult - you may still be bitten by the linux OOM killer even if things have seemed stable for a long time, so plan your alerts and/or
    #       ASG healthcheck replacement type accordingly.
    if [ $MEM_TOTAL_KB -lt 1000000 ]
    then
        # This is a t2.nano with 500MB total RAM
        MEM_RESERVED_FOR_OS_KB=300000
    elif [ $MEM_TOTAL_KB -lt 2000000 ]
    then
        # This is a t2.micro with 1GB total RAM
        MEM_RESERVED_FOR_OS_KB=600000
    else
        # The smallest instance this could be is a t2.small with 2 GB total RAM
        MEM_RESERVED_FOR_OS_KB=1250000
    fi

    MEM_AVAILABLE_FOR_APP_KB=`expr $MEM_TOTAL_KB - $MEM_RESERVED_FOR_OS_KB`
    NEW_GEN_SIZE_KB=`expr $MEM_AVAILABLE_FOR_APP_KB / 3`
    JVM_MEMORY_ARGS=" -Xmx${MEM_AVAILABLE_FOR_APP_KB}k -Xms${MEM_AVAILABLE_FOR_APP_KB}k -XX:NewSize=${NEW_GEN_SIZE_KB}k"
fi

if [ -z "$JVM_GC_ARGS" ]
then
    JVM_GC_ARGS=" -XX:+UseConcMarkSweepGC -XX:SurvivorRatio=6"
fi

if [ -z "$JVM_GC_LOGGING_ARGS" ]
then
    JVM_GC_LOGGING_ARGS=" -Xloggc:/var/log/cms/gc.log -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=4 -XX:GCLogFileSize=64M \
-verbose:gc -XX:+PrintGCDetails -XX:+PrintGCApplicationStoppedTime -XX:+PrintGCTimeStamps -XX:+PrintHeapAtGC -XX:+PrintTenuringDistribution"
fi

if [ -z "$JVM_HEAP_DUMP_ON_OOM_ARGS" ]
then
    JVM_HEAP_DUMP_ON_OOM_ARGS=" -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/var/log/cms/"
fi

if [ -z "$JVM_DNS_TTL" ]
then
    JVM_DNS_TTL=" -Dsun.net.inetaddr.ttl=60"
fi

export JVM_BEHAVIOR_ARGS="${JVM_MEMORY_ARGS} \
${JVM_GC_ARGS} \
${JVM_GC_LOGGING_ARGS} \
${JVM_HEAP_DUMP_ON_OOM_ARGS} \
${JVM_DNS_TTL} \
-XX:-OmitStackTraceInFastThrow -Duser.timezone=UTC -Dfile.encoding=UTF8 -server"