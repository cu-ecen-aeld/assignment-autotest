#!/bin/bash
# Script to start qemu
#Author: Siddhant Jajoo.

source poky/oe-init-build-env
export QB_SLIRP_OPT="-netdev user,id=net0,hostfwd=tcp::10022-:22,hostfwd=tcp::9000-:9000"
runqemu slirp nographic
