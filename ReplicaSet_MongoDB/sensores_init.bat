@echo off
start "Server S1" /MIN mongod --config "C:\Users\wilio\Documents\GitHub\PISID\ReplicaSet_MongoDB\server1\server1.conf"
start "Server S2" /MIN mongod --config "C:\Users\wilio\Documents\GitHub\PISID\ReplicaSet_MongoDB\server2\server2.conf"
start "Server S3" /MIN mongod --config "C:\Users\wilio\Documents\GitHub\PISID\ReplicaSet_MongoDB\server3\server3.conf"
