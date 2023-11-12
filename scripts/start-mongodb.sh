#!/bin/bash
# set -o pipefail

# Replica set keys must be between 6 and 1024 characters in length and consist of only valid base64 characters.
# See https://www.mongodb.com/docs/v6.2/tutorial/deploy-replica-set-with-keyfile-access-control/#create-a-keyfile
# for details.
echo -n "${REPLICA_SET_KEY}" | base64 > /replica-set-key
chmod 0400 /replica-set-key
chown 999:999 /replica-set-key

/usr/local/bin/docker-entrypoint.sh mongod --replSet rs0 --bind_ip localhost,mongodb --keyFile /replica-set-key
