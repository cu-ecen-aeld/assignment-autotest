#!/bin/bash
pushd `dirname $0`
basedir_relative=../../
basedir_abs=`realpath ${basedir_relative}`
docker run -it -v ${basedir_abs}:${basedir_abs} -w="${basedir_abs}" cuaesd/aesd-autotest ./test.sh
