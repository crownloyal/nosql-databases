#!/bin/bash
# # # # # # #
# INCLUDES  #
# # # # # # #
source ./var/common/log.sh

cleanUp() {
    local LOG=./var/logs/setup.log

    rm -rf ./var/logs
    setupLog $LOG

    writeToLog $LOG "INFO: Killing mongod and mongos"
    killall mongod
    killall mongos

    writeToLog $LOG "INFO: Removing data files"
    rm -rf ./data/
    > ./var/config/node.map
}

cleanUp