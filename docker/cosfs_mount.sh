#!/bin/bash 

fmt_info(){
  printf '%s info: %s\n' "$(date \"+%Y-%m-%d %H:%M:%S\")" "$*" 
}

set -e

# calc min(2GB, Mem/4)
min_memory_mb=$(grep MemTotal /proc/meminfo | awk '{printf("%.0f", $2 / 1024 / 4)}' | awk '{print ($1 < 2048) ? $1 : 2048}')

# use tmpfs(mem) as cosfs cache
mkdir -p /cos_tmpfs &&  mount -t tmpfs -o size="${min_memory_mb}"M tmpfs /cos_tmpfs



COS_OPTIONS="$COS_OPTIONS -ocam_role=sts -oallow_other -ouse_cache=/cos_tmpfs -odel_cache -odisable_content_md5 -oensure_diskfree=128"

if [ -z "$PARALLEL_COUNT" ]; then
COS_OPTIONS="$COS_OPTIONS -oparallel_count=32 -omultireq_max=32"
else
COS_OPTIONS="$COS_OPTIONS -oparallel_count=$PARALLEL_COUNT -omultireq_max=$PARALLEL_COUNT"
fi

if [ -z "$MULTIPART_SIZE" ]; then
COS_OPTIONS="$COS_OPTIONS -omultipart_size=32"
else
COS_OPTIONS="$COS_OPTIONS -omultipart_size=$MULTIPART_SIZE"
fi

restartPolicy=${RESTART_POLICY:-Always}

if [[ "${restartPolicy}" =~ "Always" ]]; then 
  COS_OPTIONS="$COS_OPTIONS -f"
fi





mkdir -p "$MOUNT_PATH"
if [ -z "$QCLOUD_TMS_CREDENTIALS_URL" ]; then 
  eval /cosfs "$BUCKET" "$MOUNT_PATH" -ourl="$COS_URL" -opasswd_file="$PASSWD_FILE" "$COS_OPTIONS"
else
  eval /cosfs "$BUCKET" "$MOUNT_PATH" -ourl="$COS_URL" -otmp_credentials_url="$QCLOUD_TMS_CREDENTIALS_URL" "$COS_OPTIONS"
fi


if [[ "${restartPolicy}" == "Never" ]] || [[ "${restartPolicy}" == "OnFailure" ]] ; then

# 1. check the other container created
for i in {1..3}; do
    is_cosfs_mount=$(df -h |grep cosfs)

    if [ -n "$is_cosfs_mount" ]; then 
        fmt_info "cosfs is mounted"
        break
    fi 

    fmt_info "wait cosfs mount at $i times"
    sleep 10s
done

# 2. wait other containers exit 
/sidecar wait

fi 




exit 0