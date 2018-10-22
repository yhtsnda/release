#!/bin/bash

RBD_REPO="https://github.com/goodrain/rainbond.git"
VERSION=V3.7
RELEASE_VERSION=3.7.2
WORKSPACE=/tmp/rainbond
WORK_DIR=/go/src/github.com/goodrain/rainbond
GO_VERSION=1.11

git clone --depth 1 -b ${VERSION} ${RBD_REPO} ${WORKSPACE}/rainbond/

pushd ${WORKSPACE}/rainbond/
    buildTime=$(date +%F-%H)
    git_commit=$(git log -n 1 --pretty --format=%h)
    release_desc=${RELEASE_VERSION}-${git_commit}-${buildTime}
    releasedir=./.release/dist/usr/local/bin
    mkdir -p $releasedir
    echo "build node"
    docker run --rm -v `pwd`:${WORK_DIR} -w ${WORK_DIR} -it golang:${GO_VERSION} go build -ldflags "-w -s -X github.com/goodrain/rainbond/cmd.version=${release_desc}"  -o $releasedir/node ./cmd/node
	echo "build grctl"
	docker run --rm -v `pwd`:${WORK_DIR} -w ${WORK_DIR} -it golang:${GO_VERSION} go build -ldflags "-w -s -X github.com/goodrain/rainbond/cmd.version=${release_desc}"  -o $releasedir/grctl ./cmd/grctl
	echo "build certutil"
	docker run --rm -v `pwd`:${WORK_DIR} -w ${WORK_DIR} -it golang:${GO_VERSION} go build -ldflags "-w -s -X github.com/goodrain/rainbond/cmd.version=${release_desc}"  -o $releasedir/grcert ./cmd/certutil
	cd $releasedir/dist/usr/local/
	tar zcf pkg.tgz `find . -maxdepth 1|sed 1d`

	cat >Dockerfile <<EOF
FROM alpine:3.6
COPY pkg.tgz /
EOF
	docker build -t rainbond/cni:rbd_v${RELEASE_VERSION} .
	#docker push rainbond/cni:rbd_v${RELEASE_VERSION}
popd