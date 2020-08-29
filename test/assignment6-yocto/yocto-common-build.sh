#!/bin/bash
# 1st argument: absolute or relative path to the base directory
# Defaults to dirname `git rev-parse --absolute-git-dir` if not specified

source script-helpers

script_dir="$(pwd -P )"
testdir=$1
pushd $testdir
# Setup keys
before_script

# Deploying build and executing test cases if successful
echo "Running build.sh"
./build.sh
rc=$?
if [ $rc -ne 0 ]; then
	add_validate_error "Build step failed with rc $?"
fi

popd
