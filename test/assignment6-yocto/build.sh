#!/bin/bash
# Script to build image for qemu.
# Author: Siddhant Jajoo.


git submodule init
git submodule sync
git submodule update

# local.conf won't exist until this step on first execution
source poky/oe-init-build-env

CONFLINE="MACHINE = \"qemuarm64\""

cat conf/local.conf | grep "${CONFLINE}" > /dev/null
local_conf_info=$?

if [ $local_conf_info -ne 0 ];then
	echo "Append ${CONFLINE} in the local.conf file"
	echo ${CONFLINE} >> conf/local.conf
	
else
	echo "${CONFLINE} already exists in the local.conf file"
fi

# Customizations for autograder to use shared download, state, and tmpdir
mkdir -p /var/aesd/yocto-shared/downloads

DL_DIR_LINE="DL_DIR = \"/var/aesd/yocto-shared/downloads\""
cat conf/local.conf | grep "${DL_DIR_LINE}" > /dev/null
if [ $? -ne 0 ]; then
	echo ${DL_DIR_LINE} >> conf/local.conf
fi

bitbake-layers show-layers | grep "meta-aesd" > /dev/null
layer_info=$?

if [ $layer_info -ne 0 ];then
	echo "Adding meta-aesd layer"
	bitbake-layers add-layer ../meta-aesd
else
	echo "meta-aesd layer already exists"
fi

set -e
bitbake core-image-aesd

