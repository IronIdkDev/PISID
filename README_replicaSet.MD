# HOW TO START THE REPLICA SET IN YOUR PC: (These instructions assume you used Github Desktop)

Open 3 terminals and run the following commands in each terminal:

## 1. In the first terminal, run the following command:

mongod --port 27015 --dbpath C:\Users\YOUR_USER\Documents\GitHub\PISID\ReplicaSet_MongoDB\server1\data --replSet Sensores

## 2. In the second terminal, run the following command:

mongod --port 25015 --dbpath C:\Users\YOUR_USER\Documents\GitHub\PISID\ReplicaSet_MongoDB\server2\data --replSet Sensores

## 3. In the third terminal, run the following command:

mongod --port 23015 --dbpath C:\Users\YOUR_USER\Documents\GitHub\PISID\ReplicaSet_MongoDB\server3\data --replSet Sensores

## Open a fourth terminal and run the following command:

mongosh --port 27015

This should start the mongo shell. Now, in the mongo shell, run the following commands:

rs.initiate()

rs.add("localhost:25015")
rs.add("localhost:23015")

And finally run the following command to check the status of the replica set:

rs.status() // check status

Everything should be working. 

## Before you continue, head to the 'sensores_init.bat' file and change the path to your own path (if all of this worked, that you'll probably only have to change the user 'wilio' to your own).
From now on, if this works, then 'sensores_init.bat' will start the replica set.
