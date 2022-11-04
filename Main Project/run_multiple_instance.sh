#!/bin/sh

# this script runs the app in server mode with multiple instances
# use first ($1) argument to define the ip

echo "run multiple instance"
echo "ip address = $1"

godot-server . --server --port=1235 --ip=$1 & # for univercity space
godot-server . --server --port=1236 --ip=$1 & # for library space
godot-server . --server --port=1237 --ip=$1   # for office space