#!/bin/bash
# # # # # # #
# INCLUDES  #
# # # # # # #
source ./var/common/log.sh

writeToLog "INFO: Killing mongod and mongos"
killall mongod
killall mongos

writeToLog "INFO: Removing data files"
rm -rf ./data/
rm -rf ./var/logs
> ./var/config/node.map