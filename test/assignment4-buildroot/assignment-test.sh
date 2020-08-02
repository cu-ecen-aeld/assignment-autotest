#!/bin/bash
# 1st argument: absolute or relative path to the base directory
# Defaults to dirname `git rev-parse --absolute-git-dir` if not specified

cd `dirname $0`

source script-helpers
source assignment-timeout

script_dir="$(pwd -P )"
testdir=$1
qemu_executable_path=/bin	#Path where writer,finder,tester.sh are stored

# Invoke docker script with --env SKIP_BUILD=1 --env DO_VALIDATE=1 to perform a validation only
# test
echo "starting test with SKIP_BUILD ${SKIP_BUILD} and DO_VALIDATE ${DO_VALIDATE}"
if [[ -z ${SKIP_BUILD} || ${SKIP_BUILD} -eq 0 ]]; then
    . ./assignment-4-build.sh ${testdir}
    rc=$?
    echo "build step complete with status $?"
    echo "Validation errors ${validate_error}"
fi


if [[ -z ${DO_VALIDATE} || ${DO_VALIDATE} -eq 1 ]]; then
    echo "Starting validation step"
	pushd ${testdir}

	# Running qemu instance in background
	validate_qemu

	# Validating test cases inside qemu
	validate_assignment2_checks "${script_dir}" "${qemu_executable_path}"

    add_validate_error "catchme"

	echo "Killing qemu"
	killall qemu-system-aarch64
	popd
fi

if [ ! -z "${validate_error}" ]; then
    echo "Validation failed with error list ${validate_error}"
    exit 1
fi
exit 0
