#!/bin/bash 

# wait cosfs process mount the cos
for i in {1..3}; do
    is_cosfs_mount=$(df -h |grep cosfs)

    if [ -n "$is_cosfs_mount" ]; then 
        echo "cosfs is mounted"
        break
    fi 

    echo "wait cosfs mount at $i times"
    sleep 1s
done


# watch main process process runing
count=0
while true; do
  
  # 获取非 cosfs、非 pause、非 defunct 进程数量
  non_cosfs_count=$(pgrep -v -c -f "UID|/cosfs|sleep|pause|defunct")
 
  # 如果非 cosfs、非 pause、非 defunct 进程数量为 0，则退出循环
  if [ "$non_cosfs_count" -eq 0 ]; then
    echo "No other process found, this take $count times"
    count=$((count+1))
  else
    echo "There are other process alive, cosfs will working"
    count=0     
  fi

  if [ $count -eq 6 ]; then
    echo "No other process found $count times, maybe the other container is dead? i will kill cosfs"
    break
  fi

  sleep 10 
done



kill -s SIGTERM $(pgrep cosfs)
exit 0