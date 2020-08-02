#!/bin/bash
# 1st argument: absolute or relative path to the base directory
# Defaults to dirname `git rev-parse --absolute-git-dir` if not specified

source script-helpers
source assignment-timeout

script_dir="$( cd "$(dirname "$0")" ; pwd -P )"
testdir=$1


# Invoke docker script with --env SKIP_BUILD=1 --env DO_VALIDATE=1 to perform a validation only
echo "starting test with SKIP_BUILD ${SKIP_BUILD} and DO_VALIDATE ${DO_VALIDATE}"
if [[ -z ${SKIP_BUILD} || ${SKIP_BUILD} -eq 0 ]]; then
    . ./assignment-4-build.sh ${testdir}
fi


if [[ -z ${DO_VALIDATE} || ${DO_VALIDATE} -eq 1 ]]; then
	pushd ${testdir}

	# Running qemu instance in background
	validate_qemu

	# Validating test cases inside qemu
	validate_assignment2_checks "${script_dir}" "${qemu_executable_path}"

	echo "Killing qemu"
	killall qemu-system-aarch64
	popd
fi
