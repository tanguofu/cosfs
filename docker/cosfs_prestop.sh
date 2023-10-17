#!/bin/bash 

fmt_warn() {
  printf '%s warn: %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

fmt_info(){
  printf '%s info: %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" 
}

if [ ! -d "$MOUNT_PATH" ]; then
  fmt_info "$MOUNT_PATH is not exists"
  exit 0
fi

mountpoint -q "$MOUNT_PATH"
if [ $? -eq 0 ]; then  
  umount -u "$MOUNT_PATH"
  fmt_warn "fusermount -u $MOUNT_PATH ret:$?"
fi  


exit 0