#!/bin/bash 

fmt_warn() {
  printf '%s warn: %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

fmt_info(){
  printf '%s info: %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" 
}

# wait cosfs process mount the cos
for i in {1..12}; do
    
    mountpoint "$MOUNT_PATH"
    is_cosfs_mount=$?

    if [ "$is_cosfs_mount" -eq 0 ]; then 
        fmt_info "$MOUNT_PATH cosfs is mounted, exit check"
        exit 0
    fi 

    fmt_warn "wait cosfs mount at $i times"
    sleep 5s
done

fmt_warn "$MOUNT_PATH cosfs mount check failed "
exit 200