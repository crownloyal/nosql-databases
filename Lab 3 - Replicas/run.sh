#!/bin/bash
# # # # # # #
# INCLUDES  #
# # # # # # #
source ./setup.sh
source ./configure.sh

# # # # # # # #
# R U N . SH  #
# # # # # # # #

# clean everything up
clearRemnants && setupLog
wait

# For mac make sure rlimits are high enough to open all necessary connections
ulimit -n 2048

# create shards
createReplicas && createConfigServers
wait