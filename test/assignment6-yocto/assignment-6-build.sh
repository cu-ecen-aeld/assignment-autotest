#!/bin/bash
# 1st argument: absolute or relative path to the base directory
# Defaults to dirname `git rev-parse --absolute-git-dir` if not specified

source script-helpers

script_dir="$(pwd -P )"
testdir=$1
qemu_executable_path=/usr/bin	#Path where writer,finder,tester.sh are stored
ROOTFS_PATH=build/tmp/work/qemuarm64-poky-linux/core-image-aesd/1.0-r0/rootfs		# add ${script_dir} before buildroot to make it an absolute path 

pushd ${testdir}
. ${script_dir}/yocto-common-build.sh $ROOTFS_PATH
popd
