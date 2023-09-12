#!/bin/bash 

fmt_info(){
  printf '%s info: %s\n' "$(date \"+%Y-%m-%d %H:%M:%S\")" "$*" 
}

set -e

# calc min(2GB, Mem/4)
min_memory_mb=$(grep MemTotal /proc/meminfo | awk '{printf("%.0f", $2 / 1024 / 4)}' | awk '{print ($1 < 2048) ? $1 : 2048}')

COS_OPTIONS="$COS_OPTIONS -ocam_role=sts -oallow_other  -odisable_content_md5  -odbglevel=warn"

if [ -n "$USE_MEM_CACHE" ]; then
  mkdir -p /cos_tmpfs && mount -t tmpfs -o size="${min_memory_mb}"M tmpfs /cos_tmpfs
  COS_OPTIONS="$COS_OPTIONS -ouse_cache=/cos_tmpfs -odel_cache -oensure_diskfree=64"
else
  COS_OPTIONS="$COS_OPTIONS -ouse_cache=/tmp -odel_cache -oensure_diskfree=2048"
fi

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
  echo "restartPolicy:$restartPolicy donot check sidecar status"
else
  echo "restartPolicy:$restartPolicy start check sidecar status"
  /cosfs_watcher.sh &
fi

mkdir -p "$MOUNT_PATH"
if [ -z "$QCLOUD_TMS_CREDENTIALS_URL" ]; then 
  eval /cosfs-mount "$BUCKET" -f "$MOUNT_PATH" -ourl="$COS_URL" -opasswd_file="$PASSWD_FILE" "$COS_OPTIONS"
else
  eval /cosfs-mount "$BUCKET" -f "$MOUNT_PATH" -ourl="$COS_URL" -otmp_credentials_url="$QCLOUD_TMS_CREDENTIALS_URL" "$COS_OPTIONS"
fi

exit 0