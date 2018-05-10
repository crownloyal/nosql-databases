#!/bin/bash
# # # # # # #
# INCLUDES  #
# # # # # # #
source ./var/common/log.sh

function routedir() {
    local LOGFILE=./var/logs/setup.log

    if [ $# -ne 1 ]; then
        writeToLog $LOGFILE "ERR: Sequence aborted, missing params."
        writeToLog $LOGFILE "Function routedir() requires 1 param"
        writeToLog $LOGFILE "1: data centre"
        exit 100
    fi

    local LOCATION=$1
    mkdir -p ./data/$LOCATION/route
    mkdir -p ./var/logs/$LOCATION/route
}

routerPortList() {
    local LOGFILE=./var/logs/setup.log
    local DATACENTRE=$1

    local HOSTLIST=$(findLineAttribute "host" "host")
    local PORTLIST=$(findAllPorts $DATACENTRE)
    local LIST=""

    while read port; do
        writeToLog LOGFILE "DEBUG: Current PORT :$port"
        LIST+="$HOSTLIST:$port,"
    done < "$PORTLIST"

    writeToLog $LOGFILE "DEBUG: Routerlist - $LIST"

    echo $LIST
}

function startRouter() {
    local LOGFILE=./var/logs/setup.log

    if [ $# -ne 1 ]; then
        writeToLog $LOGFILE "ERR: Sequence aborted, missing params."
        writeToLog $LOGFILE "Function startRouter() requires 2 params"
        writeToLog $LOGFILE "1: data centre"
        exit 100
    fi

    local DATACENTRE=$1
    local ROUTESERVERCOUNT=$(findLineAttribute "rout" "count")
    local PORTLIST=$(routerPortList $DATACENTRE)


    for ((i=0;i<$ROUTESERVERCOUNT;i++)); do
        local PORT=$(countUp $(findValidLastPort) 5)
        ./var/common/startRouterNode.sh $DATACENTRE $PORT $PORTS
    done
}


createRoutes() {
    local LOGFILE=./var/logs/setup.log
    local DATACENTRES=$(getFilePath "dc")

    while read location; do
        writeToLog $LOGFILE "INFO: Setting up router server for $location"

        routedir $location
        startRouter $location
    done < $DATACENTRES
}

# now start the mongos on port 27018
# rm mongos-1.log
# sleep 5
# mongos --port 59001 --logpath "./data/mongos-1.log" --configdb configServers/localhost:55001,localhost:55002,localhost:55003 
# echo "Waiting 60 seconds for the replica sets to fully come online"
# sleep 60
# echo "Connnecting to mongos and enabling sharding"

# # add shards and enable sharding on the test db
# mongo --port 27018 --eval 'db.adminCommand( { addshard : "s0/"+"localhost:45001" } );db.adminCommand( { addshard : "s1/"+"localhost:46001" } );db.adminCommand( { addshard : "s2/"+"localhost:47001" } );db.adminCommand({enableSharding: "test"});'

# sleep 5
# echo "Done setting up sharded environment on localhost"