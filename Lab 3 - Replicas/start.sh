#!/bin/bash

source ./replica.sh

# # # # # # # #
# R U N . SH  #
# # # # # # # #

# clean everything up
clearRemnants
setupLog

# For mac make sure rlimits are high enough to open all necessary connections
ulimit -n 2048

# create shards
createReplicas $(getFilePath "dc")