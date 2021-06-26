#!/bin/bash
testdir=$1
pushd `dirname $0`
scriptdir=$(pwd -P)
source script-helpers

validate_assignment5_native "${scriptdir}" "${testdir}/server"

if [ ! -z "${validate_error}" ]; then
    echo "Validation failed with error list ${validate_error}"
    exit 1
fi
