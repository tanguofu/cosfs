#!/bin/bash 

fmt_error() {
  printf '%s error: %s\n' "$(date \"+%Y-%m-%d %H:%M:%S\")" "$*" >&2
}

fmt_info(){
  printf '%s info: %s\n' "$(date \"+%Y-%m-%d %H:%M:%S\")" "$*" 
}

# wait cosfs process mount the cos
for i in {1..3}; do
    is_cosfs_mount=$(df -h |grep cosfs)

    if [ -n "$is_cosfs_mount" ]; then 
        fmt_info "cosfs is mounted"
        break
    fi 

    fmt_info "wait cosfs mount at $i times"
    sleep 3s
done


restartPolicy=${RESTART_POLICY:-Always}
if [[ "${restartPolicy}" =~ "Never" ]] || [[ "${restartPolicy}" =~ "OnFailure" ]] ; then
  fmt_info "restartPolicy is ${restartPolicy}, kill cosfs when no other process found, to terminal the job normal"
else
  exit 0
fi 


# watch main process process runing
count=0
while true; do
  
  # 获取非 cosfs、非 pause、非 defunct 进程数量
  non_cosfs_count=$(pgrep -v -c -f "UID|/cosfs|sleep|pause|defunct")
 
  # 如果非 cosfs、非 pause、非 defunct 进程数量为 0，则退出循环
  if [ "$non_cosfs_count" -eq 0 ]; then
    fmt_error "No other process found, this take $count times"
    count=$((count+1))
  else
    fmt_info "There are other process alive, cosfs will working"
    count=0     
  fi

  if [ $count -eq 6 ]; then
    fmt_error "No other process found $count times about one minus, maybe the other container is dead? i will kill cosfs"
    break
  fi

  sleep 10 
done


kill -s SIGTERM $(pgrep cosfs)
exit 0