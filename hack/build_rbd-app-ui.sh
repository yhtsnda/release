#!/bin/bash

UI_REPO="https://github.com/goodrain/rainbond-ui.git"
CONSOLE_REPO="https://github.com/goodrain/rainbond-console.git"
VERSION=3.7
WORKSPACE=/tmp/rainbond

git clone --depth 1 -b ${VERSION} ${UI_REPO} ${WORKSPACE}/ui 
pushd ${WORKSPACE}/ui
make all
popd

git clone --depth 1 -b ${VERSION} ${CONSOLE_REPO} ${WORKSPACE}/console
pushd ${WORKSPACE}/console
rm -rf  ${WORKSPACE}/console/www/static/dists/index.*
cp -a ${WORKSPACE}/ui/dist/index.* ${WORKSPACE}/console/www/static/dists/
./release.sh
popd
