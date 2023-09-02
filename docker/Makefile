DATE:=${shell date "+%Y%m%d"}
COMMITID:=${shell git rev-parse --short HEAD}
BRANCH:=${shell git symbolic-ref --short -q HEAD|tr / _}
TAG?=${BRANCH}-${COMMITID}-${DATE}

COSFS_IMAGE?=ccr.ccs.tencentyun.com/qcloud-ti-platform/cosfs:${TAG}
all: images


images: 
	docker build  -t ${COSFS_IMAGE} -f cosfs-dockerfile ..
push:
	docker push ${COSFS_IMAGE}
