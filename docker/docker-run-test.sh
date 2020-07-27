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

if [ ! -e ~/.ssh/id_rsa_aesd_nopassword ] && [ -z "${SSH_PRIVATE_KEY}" ]; then
    echo "Please create an ssh key with access to AESD repositories and no password"
    echo "Then place at ~/.ssh/id_rsa_aesd_nopassword"
    echo "Alternatively, you can define environment variable SSH_PRIVATE_KEY"
    exit 1
fi

if [ -z "${SSH_PRIVATE_KEY}" ]; then
    echo "Setting private key based on keyfile"
    export SSH_PRIVATE_KEY=`cat ~/.ssh/id_rsa_aesd_nopassword`
fi
docker run -it -v ${basedir_abs}:${basedir_abs} -v ~/.dl:/var/aesd/.dl -v /tmp:/tmp --env SSH_PRIVATE_KEY -w="${basedir_abs}" $@ cuaesd/aesd-autotest  ./test.sh --i $(id -u ${USER}) -g $(id -g ${USER})
