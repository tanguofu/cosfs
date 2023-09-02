#!/bin/bash

for i in {1..3}; do

    is_cosfs_mount=$(df -h |grep cosfs)

    if [ -n "$is_cosfs_mount" ]; then 
        echo "cosfs mount "
        exit 0
    fi 

    echo "wait cosfs mount at $i times"
    sleep 1s
done

exit 0