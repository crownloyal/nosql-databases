# clean everything up
echo "killing mongod and mongos"
killall mongod
killall mongos
echo "removing data files"
rm -rf ./data/

# For mac make sure rlimits are high enough to open all necessary connections
ulimit -n 2048

# start a replica set and tell it that it will be shard0
mkdir -p ./data/cork/shard0/rs0 ./data/cork/shard0/rs1 ./data/cork/shard0/rs2 ./data/cork/logs/
mongod --replSet s0 --logpath "./data/cork/logs/s0-r0.log" --dbpath ./data/cork/shard0/rs0 --port 45001 --shardsvr --smallfiles &&
mongod --replSet s0 --logpath "./data/cork/logs/s0-r1.log" --dbpath ./data/cork/shard0/rs1 --port 45002 --shardsvr --smallfiles &&
mongod --replSet s0 --logpath "./data/cork/logs/s0-r2.log" --dbpath ./data/cork/shard0/rs2 --port 45003 --shardsvr --smallfiles &&

sleep 5
# connect to one server and initiate the set
mongo --port 45001 --eval 'config = { _id: "s0", members:[{ _id : 0, host : "localhost:45001" },{ _id : 1, host : "localhost:45002" },{ _id : 2, host : "localhost:45003" }]};rs.initiate(config)'

# start a replicate set and tell it that it will be a shard1
mkdir -p ./data/dublin/shard1/rs0 ./data/dublin/shard1/rs1 ./data/dublin/shard1/rs2 ./data/dublin/logs/
mongod --replSet s1 --logpath "./data/dublin/logs/s1-r0.log" --dbpath ./data/dublin/shard1/rs0 --port 46001 --shardsvr --smallfiles
mongod --replSet s1 --logpath "./data/dublin/logs/s1-r1.log" --dbpath ./data/dublin/shard1/rs1 --port 46002 --shardsvr --smallfiles
mongod --replSet s1 --logpath "./data/dublin/logs/s1-r2.log" --dbpath ./data/dublin/shard1/rs2 --port 46003 --shardsvr --smallfiles

sleep 5
mongo --port 46001 --eval 'config = { _id: "s1", members:[{ _id : 0, host : "localhost:46001" },{ _id : 1, host : "localhost:46002" },{ _id : 2, host : "localhost:46003" }]};rs.initiate(config)'

# start a replicate set and tell it that it will be a shard2
mkdir -p ./data/newyork/shard2/rs0 ./data/newyork/shard2/rs1 ./data/newyork/shard2/rs2 ./data/newyork/logs/
mongod --replSet s2 --logpath "./data/newyork/logs/s2-r0.log" --dbpath ./data/newyork/shard2/rs0 --port 47001 --shardsvr --smallfiles
mongod --replSet s2 --logpath "./data/newyork/logs/s2-r1.log" --dbpath ./data/newyork/shard2/rs1 --port 47002 --shardsvr --smallfiles
mongod --replSet s2 --logpath "./data/newyork/logs/s2-r2.log" --dbpath ./data/newyork/shard2/rs2 --port 47003 --shardsvr --smallfiles

sleep 5
mongo --port 47001 --eval 'config = { _id: "s2", members:[{ _id : 0, host : "localhost:47001" },{ _id : 1, host : "localhost:47002" },{ _id : 2, host : "localhost:47003" }]};rs.initiate(config)'

# now start 3 config servers
rm cfg-a.log cfg-b.log cfg-c.log
mkdir -p ./data/config/config-a ./data/config/config-b ./data/config/config-c
mongod --logpath "./data/config/logs/cfg-a.log" --dbpath ./data/config/config-a --port 55001 --configsvr --smallfiles
mongod --logpath "./data/config/logs/cfg-b.log" --dbpath ./data/config/config-b --port 55002 --configsvr --smallfiles
mongod --logpath "./data/config/logs/cfg-c.log" --dbpath ./data/config/config-c --port 55003 --configsvr --smallfiles


# now start the mongos on port 27018
rm mongos-1.log
sleep 5
mongos --port 59001 --logpath "./data/mongos-1.log" --configdb configServers/localhost:55001,localhost:55002,localhost:55003 
echo "Waiting 60 seconds for the replica sets to fully come online"
sleep 60
echo "Connnecting to mongos and enabling sharding"

# add shards and enable sharding on the test db
mongo --port 27018 --eval 'db.adminCommand( { addshard : "s0/"+"localhost:45001" } );db.adminCommand( { addshard : "s1/"+"localhost:46001" } );db.adminCommand( { addshard : "s2/"+"localhost:47001" } );db.adminCommand({enableSharding: "test"});'

sleep 5
echo "Done setting up sharded environment on localhost"