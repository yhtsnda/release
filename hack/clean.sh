#!/bin/bash

os=$(uname -s)
if [ "$os" == "Darwin" ];  then
    offline_image_path="./opt/rainbond/offline/images"
else
    offline_image_path="/opt/rainbond/offline/images"
fi

rm -rf ${offline_image_path}