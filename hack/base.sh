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

r6d::done(){
    local plugins=(tcm mesh_plugin rbd-init-probe)
    local base=(rbd-dns rbd-db runner builder)

    for pimg in ${plugins[@]}
    do
        docker pull rainbond/${pimg}:${version}
        docker tag rainbond/${pimg}:${version} goodrain.me/${pimg}
        [ -f "${offline_image_path}/base/${pimg}.tgz" ] && rm -rf ${offline_image_path}/base/${pimg}.tgz
        docker save goodrain.me/${pimg}> ${offline_image_path}/base/${pimg}.tgz
    done

    for img in ${base[@]}
    do
        [ -f "${offline_image_path}/base/${img}.tgz" ] && rm -rf ${offline_image_path}/base/${img}.tgz
        docker pull rainbond/${img}
        docker tag rainbond/${img} goodrain.me/${img}
        docker save goodrain.me/${img} > ${offline_image_path}/base/${img}.tgz
    done

    docker pull rainbond/rbd-repo:6.5.9
    docker tag rainbond/rbd-repo:6.5.9 goodrain.me/rbd-repo:6.5.9
    docker save goodrain.me/rbd-repo:6.5.9 > ${offline_image_path}/base/repo.tgz
    docker pull rainbond/rbd-registry:2.6.2
    docker tag rainbond/rbd-registry:2.6.2 goodrain.me/rbd-registry:2.6.2
    docker save goodrain.me/rbd-registry:2.6.2 > ${offline_image_path}/base/hub.tgz
}

k8s::done(){
    local k8s=(kube-scheduler kube-controller-manager kube-apiserver)
    local kver="v1.10.13"
    for kimg in ${k8s[@]}
    do
        docker pull rainbond/${kimg}:${kver}
        docker tag rainbond/${kimg}:${kver} goodrain.me/${kimg}:${kver}
        [ -f "${offline_image_path}/base/${kimg}.tgz" ] && rm -rf ${offline_image_path}/base/${kimg}.tgz
        docker save goodrain.me/${kimg}:${kver} > ${offline_image_path}/base/${kimg}.tgz
    done
    docker pull rainbond/calico-node:v3.3.1
    docker tag rainbond/calico-node:v3.3.1 goodrain.me/calico-node:v3.3.1
    docker save goodrain.me/calico-node:v3.3.1 > ${offline_image_path}/base/calico.tgz
    docker pull rainbond/etcd:v3.2.25
    docker tag rainbond/etcd:v3.2.25 goodrain.me/etcd:v3.2.25
    docker save goodrain.me/etcd:v3.2.25 > ${offline_image_path}/base/etcd.tgz
    docker pull rainbond/pause-amd64:3.0
    docker tag rainbond/pause-amd64:3.0 goodrain.me/pause-amd64:3.0
    docker save goodrain.me/pause-amd64:3.0 > ${offline_image_path}/base/pause.tgz
    docker pull rainbond/adapter:5.1.0
    docker tag rainbond/adapter:5.1.0 goodrain.me/adapter
    docker save goodrain.me/adapter > ${offline_image_path}/base/adapter.tgz
    docker pull rainbond/cni:k8s_5.1.1
    docker tag rainbond/cni:k8s_5.1.1 goodrain.me/cni:k8s
    docker save goodrain.me/cni:k8s > ${offline_image_path}/base/cni_k8s.tgz
    docker pull rainbond/kubecfg:dev
    docker save rainbond/kubecfg:dev > ${offline_image_path}/base/kubecfg_dev.tgz
    docker pull rainbond/cfssl:dev
    docker save rainbond/cfssl:dev > ${offline_image_path}/base/cfssl_dev.tgz
}

do::base(){
    k8s::done
    r6d::done
}

base_tgz(){
    do::base
    pushd $offline_image_path/base
        [ -f "$offline_image_path/base.images.${buildtime}.tgz" ] && rm -rf $offline_image_path/base.images.${buildtime}.tgz
        tar zcf $offline_image_path/base.images.${buildtime}.tgz `find .  | sed 1d`
        sha256sum $offline_image_path/base.images.${buildtime}.tgz | awk '{print $1}' > $offline_image_path/base.images.${buildtime}.sha256sum.txt
	if [ "$1" == "push" ];then
		ossutil64 cp -u  $offline_image_path/base.images.${buildtime}.tgz  oss://rainbond-pkg/offline/5.1/
		ossutil64 cp -u  $offline_image_path/base.images.${buildtime}.sha256sum.txt  oss://rainbond-pkg/offline/5.1/
	fi
    popd
}

case $1 in
	base)
		base_tgz push
	;;
	*)
		base_tgz 
	;;
esac