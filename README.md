### nanobox-hooks-mongodb ![Build Status Image](https://travis-ci.org/nanobox-io/nanobox-hooks-mongodb.svg)

Replication has been disabled for now.
 - Migrating a replica set has issues because the replica config is stored in the database and it doesn't seem to want to easily reset it to the new cluster.
 - Mongo is bad at conflict resolution and prefers to drop data.
 - [Other issues with Mongo](https://aphyr.com/posts/322-jepsen-mongodb-stale-reads)