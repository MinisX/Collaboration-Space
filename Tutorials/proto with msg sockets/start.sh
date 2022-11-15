#!/bin/sh

instance=$1

for i in `seq 1 $instance`
do
	godot --debug-collisions .&
done
