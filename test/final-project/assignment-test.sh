#!/bin/bash
# 1st argument: absolute or relative path to the base directory

cd `dirname $0`

source script-helpers

script_dir="$(pwd -P )"
testdir=$1

# Invoke docker script with --env SKIP_BUILD=1 --env DO_VALIDATE=1 to perform a validation only
# test
echo "starting test with SKIP_BUILD ${SKIP_BUILD} and DO_VALIDATE ${DO_VALIDATE}"
if [[ -z ${SKIP_BUILD} || ${SKIP_BUILD} -eq 0 ]]; then
	pushd ${testdir}
    . ${script_dir}/buildroot-common-build.sh
    rc=$?
    echo "build step complete with status $?"
    echo "Validation errors ${validate_error}"
	popd
fi
