#!/bin/bash
# # # # # # #
# INCLUDES  #
# # # # # # #
source ./setup.sh
source ./configure.sh
source ./route.sh
source ./import.sh

# # # # # # # #
# R U N . SH  #
# # # # # # # #

# clean everything up
clearRemnants
setupLog ./var/logs/setup.log

# For MAC make sure rlimits are high enough to open all necessary connections
ulimit -n 2048

# create shards & meta & router
createReplicas
createConfigs
createRoutes

# import dataset
