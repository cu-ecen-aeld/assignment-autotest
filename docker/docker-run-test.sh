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

if [ ! -e ~/.ssh/id_rsa_aesd_nopassword ] && [ -z "${SSH_PRIVATE_KEY}" ] && [ -z "${SSH_PRIVATE_KEY_BASE64}" ]; then
    echo "Please create an ssh key with access to AESD repositories and no password"
    echo "Then place at ~/.ssh/id_rsa_aesd_nopassword"
    echo "Alternatively, you can define environment variable SSH_PRIVATE_KEY or SSH_PRIVATE_KEY_BASE64 with"
    echo "the content of the ssh private key or base64uuencoded prviate key"
    exit 1
fi

if [ -z "${SSH_PRIVATE_KEY}" ]; then
    echo "Setting private key based on keyfile"
    export SSH_PRIVATE_KEY=`cat ~/.ssh/id_rsa_aesd_nopassword`
fi
assignment=`cat ${basedir_abs}/conf/assignment.txt`
touch ${basedir_abs}/test.sh.log
docker_volumes="-v ${basedir_abs}:${basedir_abs} -v ${HOME}/.dl:/var/aesd/.dl -v /tmp:/tmp -v ${basedir_abs}/test.sh.log:${basedir_abs}/test.sh.log"
docker_environment="--env SSH_PRIVATE_KEY --env SSH_PRIVATE_KEY_BASE64"
docker run -it ${docker_volumes} ${docker_environment} -w="${basedir_abs}" $@ cuaesd/aesd-autotest:${assignment}  ./test.sh --i $(id -u ${USER}) -g $(id -g ${USER})
