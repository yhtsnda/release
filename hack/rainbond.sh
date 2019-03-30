#!/bin/bash

set -xe

version=$(cat $PWD/hack/version)
os=$(uname -s)
if [ "$os" == "Darwin" ];  then
    offline_image_path="./opt/rainbond/offline/images"
else
    offline_image_path="/opt/rainbond/offline/images"
fi
mkdir -pv ${offline_image_path}/{base,rainbond,offline}

buildtime="2019-03-29-5.1.2"

rainbond=(mq eventlog webcli gateway worker chaos api app-ui monitor)


rainbond_images(){
    for img in ${rainbond[@]}
    do
        docker pull rainbond/rbd-${img}:${version}
        docker tag rainbond/rbd-${img}:${version} goodrain.me/rbd-${img}:${version}
        [ -f "${offline_image_path}/rainbond/${img}.tgz" ] && rm -rf ${offline_image_path}/rainbond/${img}.tgz
        docker save goodrain.me/rbd-${img}:${version} > ${offline_image_path}/rainbond/${img}.tgz
    done
    docker pull rainbond/cni:rbd_${version}
    docker save rainbond/cni:rbd_${version} > ${offline_image_path}/rainbond/cni_rbd.tgz
}

rainbond_tgz(){
    rainbond_images
    pushd $offline_image_path/rainbond
        [ -f "$offline_image_path/rainbond.images.${buildtime}.tgz" ] && rm -rf $offline_image_path/rainbond.images.${buildtime}.tgz
        tar zcf $offline_image_path/rainbond.images.${buildtime}.tgz `find .  | sed 1d`
        sha256sum  $offline_image_path/rainbond.images.${buildtime}.tgz | awk '{print $1}' > $offline_image_path/rainbond.images.${buildtime}.sha256sum.txt
	if [ "$1" == "push" ];then
		ossutil64 cp  -u $offline_image_path/rainbond.images.${buildtime}.tgz  oss://rainbond-pkg/offline/5.1/
        ossutil64 cp  -u $offline_image_path/rainbond.images.${buildtime}.sha256sum.txt  oss://rainbond-pkg/offline/5.1/
	fi
    popd
}

case $1 in
	rainbond)
		rainbond_tgz push
	;;
	*)
		rainbond_tgz 
	;;
esac