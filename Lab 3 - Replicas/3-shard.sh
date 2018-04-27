#!/bin/bash
# # # # # # #
# INCLUDES  #
# # # # # # #
. /var/common/log.sh

function startMgs() {
    mongos --port 59001 --logpath "./data/mongos-1.log" --configdb configServers/localhost:55001,localhost:55002,localhost:55003 
}


#createShards $DC

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