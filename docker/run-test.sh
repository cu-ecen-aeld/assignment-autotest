#!/bin/bash
# Runs the test environment in the same docker container used
# for the automated test CI environment.  This should allow you to 
# reproduce CI builds on your local machine.
# You should call this from the base directory of your repository (the one
# which contains test.sh)
basedir_abs=$(realpath .)
printenv
if [ ! -f ${basedir_abs}/full-test.sh ]; then
    echo "Please run this script from a directory containing a full-test.sh file (typically the root of your repo)"
    exit 1
fi
assignment=$(cat ${basedir_abs}/conf/assignment.txt)
if [ ! -e ~/.ssh/id_rsa_aesd_nopassword ] && [ -z "${SSH_PRIVATE_KEY}" ] && [ -z "${SSH_PRIVATE_KEY_BASE64}" ]; then
    echo "Please create an ssh key with access to AESD repositories and no password"
    echo "Then place at ~/.ssh/id_rsa_aesd_nopassword"
    echo "Alternatively, you can define environment variable SSH_PRIVATE_KEY or SSH_PRIVATE_KEY_BASE64 with"
    echo "the content of the ssh private key or base64 uuencoded prviate key"
    if [ -e ${basedir_abs}/conf/requres-ssh-key ]; then
        echo "Failing here since assignment ${assignment} requires SSH key"
        exit 1
    else
        echo "Attempting to run test without SSH key"
    fi
else
    if [ -z "${SSH_PRIVATE_KEY}" ] && [ -z "${SSH_PRIVATE_KEY_BASE64}" ]; then
        echo "Setting private key based on keyfile"
        export SSH_PRIVATE_KEY=`cat ~/.ssh/id_rsa_aesd_nopassword`
    fi
fi

if [ -z "${assignment}" ]; then
    echo "No assignment specified, using latest docker container"
else
    echo "Using container for assignment ${assignment}"
    dockertag=":${assignment}"
fi
docker_volumes="-v ${basedir_abs}:${basedir_abs}"
docker_volumes+=" -v ${HOME}/.dl:/home/autotest-admin/.dl"
docker_volumes+=" -v ${HOME}/.dl:${HOME}/.dl"
docker_volumes+=" -v /tmp:/tmp"
docker_environment="--env SSH_PRIVATE_KEY --env SSH_PRIVATE_KEY_BASE64 --env DO_VALIDATE --env SKIP_BUILD"
docker_workdir="-w=${basedir_abs}"
docker_user="-i $(id -u) -g $(id -g)"
set -x
if [ ! -z "${GITHUB_WORKSPACE}" ]; then
    docker_workdir="-w=${GITHUB_WORKSPACE}"
fi
docker run ${docker_volumes} \
        ${docker_environment} \
        ${docker_workdir} \
        $@ \
        cuaesd/aesd-autotest${dockertag} \
        ${docker_user} \
        ./full-test.sh
