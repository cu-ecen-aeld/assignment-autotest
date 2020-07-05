#!/bin/bash
# Runs the test environment in the same docker container used
# for the automated test CI environment.  This should allow you to 
# reproduce CI builds on your local machine.
# You should call this from the base directory of your repository (the one
# which contains test.sh)
basedir_abs=`realpath .`
if [ ! -f ${basedir_abs}/test.sh ]; then
    echo "Please run this script from a directory containing a test.sh file (typically the root of your repo)"
    exit 1
fi
docker run -it -v ${basedir_abs}:${basedir_abs} -v /tmp:/tmp -w="${basedir_abs}" $@ cuaesd/aesd-autotest  ./test.sh --i $(id -u ${USER}) -g $(id -g ${USER})
