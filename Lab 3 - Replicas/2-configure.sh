#!/bin/bash
# # # # # # #
# INCLUDES  #
# # # # # # #
source /var/common/log.sh

function setConfiguration() {
    CONFIG='config = { _id: "$FOLDER", members:[{ _id : 0, host : "localhost:$PORT" }]};rs.initiate(config)'

    mongo --port 45001 --eval $CONFIG
}

#setConfiguration $DC