#!/bin/sh
# set -o pipefail

# Wait for mongodb container to be ready
while true; do
  echo "[render.sh] wait for db to be ready"
  mongosh --quiet --host "${MONGO_HOST}" --username "${MONGO_INITDB_ROOT_USERNAME}" --password "${MONGO_INITDB_ROOT_PASSWORD}" --authenticationDatabase admin --eval "db.runCommand({ ping: 1 })"
  if [ $? -eq 0 ]; then
      echo "[render.sh] db is ready"
      break
  fi
  sleep 2
done

# Initiate replica set
if [ -f /var/run/replica-set ]; then
  echo "[render.sh] initiating replica set"
  mongosh --quiet --host "${MONGO_HOST}" --username "${MONGO_INITDB_ROOT_USERNAME}" --password "${MONGO_INITDB_ROOT_PASSWORD}" --authenticationDatabase admin --eval "rs.initiate($(cat /var/run/replica-set))"
  echo "[render.sh] replica set initiate status: [$?]"
fi

# Script to create user
cat <<EOF > /tmp/create-user.js
db = db.getSiblingDB('admin');
var user = { user: "${MONGO_USERNAME}", pwd: "${MONGO_PASSWORD}", roles : [ { role: "readWrite", db: "${MONGO_DATABASE}" } ]};
db.createUser(user);
EOF

# Create user
echo "[render.sh] about to create user"
mongosh --host "${MONGO_HOST}" --username "${MONGO_INITDB_ROOT_USERNAME}" --password "${MONGO_INITDB_ROOT_PASSWORD}" --authenticationDatabase admin --eval "$(cat /tmp/create-user.js)"
echo "[render.sh] user creation status: [$?]"