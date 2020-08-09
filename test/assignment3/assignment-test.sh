#!/bin/bash

./test-unit.sh
rc=$?
if [ $rc -ne 0 ]; then
    echo "Unit tests failed, skipping additional validation"
    exit $rc
fi
cd `dirname $0`
source ./script-helpers
scriptsdir=`pwd`

cd ../../../
assignment=`cat conf/assignment.txt`

. ${scriptsdir}/${assignment}-test.sh
if [ $? -ne 0 ]; then
        add_validate_error "Assignment test script for ${assignment} returned non zero exit code"
fi

if [ -n "${validate_error}" ]; then
        echo "assignment-test.sh: Validation script failed with ${validate_error} running tests for ${assignment}"
        echo "Outside QEMU: Exiting with failure"
        exit 1
fi
echo "Outside QEMU: Exiting with No validation failures, script completed successfully"
exit 0
