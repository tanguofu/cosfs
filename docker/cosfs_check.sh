#!/bin/bash 

fmt_warn() {
  printf '%s warn: %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

fmt_info(){
  printf '%s info: %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" 
}

# wait cosfs process mount the cos
for i in {1..12}; do
    is_cosfs_mount=$(df -h "$MOUNT_PATH" | grep cosfs)

    if [ -n "$is_cosfs_mount" ]; then 
        fmt_info "cosfs is mounted"
        break
    fi 

    fmt_warn "wait cosfs mount at $i times"
    sleep 3s
done

exit 0