#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

BASE_NAME=rainbond
RBD_REPO="https://github.com/goodrain/rainbond.git"
VERSION=V3.7
RELEASE_VERSION=3.7.2
WORKSPACE=/tmp/rainbond
WORK_DIR=/go/src/github.com/goodrain/rainbond
GO_VERSION=1.11
buildTime=$(date +%F-%H)
git_commit=$(git log -n 1 --pretty --format=%h)
release_desc=${RELEASE_VERSION}-${git_commit}-${buildTime}

git clone --depth 1 -b ${VERSION} ${RBD_REPO} ${WORKSPACE}/rainbond/
image_build_items=(api chaos entrance monitor mq webcli worker eventlog)
RBD_PLUGINS="{all:-1}"

build::image() {
	echo "---> Build Image:$1 FOR RBD"
	DOCKER_PATH=./hack/contrib/docker/$1
	HOME=`pwd`
	if [ "$1" = "eventlog" ];then
		docker build -t goodraim.me/event-build:v1 ${DOCKER_PATH}/build
		docker run --rm -v `pwd`:${WORK_DIR} -w ${WORK_DIR} goodraim.me/event-build:v1 go build  -ldflags "-w -s -X github.com/goodrain/rainbond/cmd.version=${release_desc}"  -o ${DOCKER_PATH}/${BASE_NAME}-$1 ./cmd/eventlog
	elif [ "$1" = "chaos" ];then
		docker run --rm -v `pwd`:${WORK_DIR} -w ${WORK_DIR} -it golang:${GO_VERSION} go build -ldflags "-w -s -X github.com/goodrain/rainbond/cmd.version=${release_desc}"  -o ${DOCKER_PATH}/${BASE_NAME}-$1 ./cmd/builder
	elif [ "$1" = "monitor" ];then
		docker run --rm -v `pwd`:${WORK_DIR} -w ${WORK_DIR} -it golang:${GO_VERSION} go build -ldflags "-w -s -extldflags '-static' -X github.com/goodrain/rainbond/cmd.version=${release_desc}" -tags 'netgo static_build' -o ${DOCKER_PATH}/${BASE_NAME}-$1 ./cmd/$1
	else
		docker run --rm -v `pwd`:${WORK_DIR} -w ${WORK_DIR} -it golang:${GO_VERSION} go build -ldflags "-w -s -X github.com/goodrain/rainbond/cmd.version=${release_desc}"  -o ${DOCKER_PATH}/${BASE_NAME}-$1 ./cmd/$1
	fi
	cd  ${DOCKER_PATH}
	sed "s/__RELEASE_DESC__/${release_desc}/" Dockerfile > Dockerfile.release
	docker build -t ${BASE_NAME}/rbd-$1:${VERSION} -f Dockerfile.release .
	rm -f ./Dockerfile.release
	rm -f ./${BASE_NAME}-$1
	cd $HOME
}


if [ "$RBD_PLUGINS" = "all" ];then
    for item in ${image_build_items[@]}
    do
        build::image ${item}
    done
else
    build::image ${RBD_PLUGINS}
fi