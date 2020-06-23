#!/bin/sh


cd `dirname $0`

. ./assignment-1-test.sh 

if [ $? -ne 0 ]; then
	add_validate_error "Inside QEMU: Failed to run assignment-1-test script"
fi

if [ ! "${validate_error}" == "" ]; then
	echo "Inside QEMU: Validation script failed with ${validate_error}"
	echo "Inside QEMU: Exiting with failure"
	exit 1
fi
echo "Inside QEMU: Exiting with No validation failures, script completed successfully"
exit 0
