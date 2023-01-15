#!/bin/bash
pushd $(dirname $0)
source script-helpers

SCRIPTS_DIR=$(pwd)
SOURCE_DIR=$(realpath ${SCRIPTS_DIR}/../../../)

pushd ${SOURCE_DIR}/finder-app

./writer.sh
rc=$?
if [ $rc -ne 1 ]; then
	add_validate_error "writer.sh should have exited with return value 1 if no parameters were specified"
fi

./writer.sh "$filedir"
rc=$?
if [ $rc -ne 1 ]; then
	add_validate_error "writer.sh should have exited with return value 1 if write string is not specified"
fi

# Run finder-test.sh with default directory and random directory
./finder-test.sh
rc=$?
if [ $rc -ne 0 ]; then
	add_validate_error "finder-test.sh execution for default directory failed with return code $rc"
fi

# generate directory name from random string
dir_name=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w32 | head -n 1)
./finder-test.sh 10 AELD_IS_FUN $dir_name

rc=$?
if [ $rc -ne 0 ]; then
	add_validate_error "finder-test.sh execution for random directory failed with return code $rc"
fi

if [ ! -z "${validate_error}" ]; then
    echo "Validation failed with error list ${validate_error}"
    exit 1
fi
