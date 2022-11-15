#!/bin/sh

echo "shut down multiple instances"

# get pid of the ports (1235, 1236, 1237)
instance1=$(lsof -t -i :1235)
instance2=$(lsof -t -i :1236)
instance3=$(lsof -t -i :1237)

# kill them if they are alive
if [ ! -z "$instance1" ]
then
    kill $instance1
    echo "instance 1 ($instance1) is killed"
else
    echo "instance 1 is dead already"
fi

if [ ! -z "$instance2" ]
then
    kill $instance2
    echo "instance 2 ($instance2) is killed"
else
    echo "instance 2 is dead already"
fi

if [ ! -z "$instance3" ]
then
    kill $instance3
    echo "instance 3 ($instance3) is killed"
else
    echo "instance 3 is dead already"
fi

echo "success"


# kill $instance1
# kill $instance2
# kill $instance3