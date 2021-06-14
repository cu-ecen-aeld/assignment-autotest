#!/bin/bash
# 1st argument: absolute or relative path to the base directory
# Defaults to dirname `git rev-parse --absolute-git-dir` if not specified

cd `dirname $0`

source script-helpers

script_dir="$(pwd -P )"
testdir=$1
rc=0

# Invoke docker script with --env SKIP_BUILD=1 --env DO_VALIDATE=1 to perform a validation only
# test
pushd ${testdir}
echo "starting test with SKIP_BUILD ${SKIP_BUILD} and DO_VALIDATE ${DO_VALIDATE}"
if [[ -z ${SKIP_BUILD} || ${SKIP_BUILD} -eq 0 ]]; then
    . ${script_dir}/buildroot-common-build.sh
    rc=$?
fi


if [[ -z ${DO_VALIDATE} || ${DO_VALIDATE} -eq 1 ]]; then
    if [ -z "${validate_error}" ]; then
        echo "Starting validation step"

        # Running qemu instance in background
        validate_qemu

        # Validating test cases inside qemu
        validate_assignment2_checks "${script_dir}" "/usr/bin/"

        echo "Killing qemu"
        killall qemu-system-aarch64
        popd
    else
        echo "Build failed, skipping validation"
    fi
fi

if [ ! -z "${validate_error}" ]; then
    echo "Validation failed with error list ${validate_error}"
    exit 1
fi
exit 0
