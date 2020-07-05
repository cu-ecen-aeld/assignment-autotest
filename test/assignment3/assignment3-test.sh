#!/bin/bash

cd `dirname $0`
source script-helpers
source assignment-timeout

scriptsdir=`pwd`
OUTDIR=/tmp/aesd-autograder

# Invoke docker script with --env SKIP_BUILD=1 --env DO_VALIDATE=1 to perform a validation only
# test
echo "starting test with SKIP_BUILD ${SKIP_BUILD} and DO_VALIDATE ${DO_VALIDATE}"
if [[ -z ${SKIP_BUILD} || ${SKIP_BUILD} -eq 0 ]]; then
    . ./assignment3-build.sh ${OUTDIR}
fi

if [[ -z ${DO_VALIDATE} || ${DO_VALIDATE} -eq 1 ]]; then
    # Go back to the test directory now that we've completed build steps
	echo "Adding necessary helper scripts to the image"
	. ./assignment-3-test-add-scripts.sh "${OUTDIR}"
	rc=$?
	if [ $rc -ne 0 ]; then
		add_validate_error "assignment-3-test-add-scripts.sh should have exited with return value 0"
	fi


	echo "Starting QEMU"
    rm -f ${OUTDIR}/qemu-out.txt 
	./test_start_qemu_terminal.sh "${OUTDIR}" | tee ${OUTDIR}/qemu-out.txt &
    sleep 10
    # See https://stackoverflow.com/a/6456103
    timeout ${qemu_timeout} grep -q "Inside QEMU: Exiting with No" <(tail -f ${OUTDIR}/qemu-out.txt)

	#rc value would be 124 if read_qemu is interrupted by timeout. 0 for success
	#read_qemu getting interrupted would mean that the either manual_linux.sh does not consist of key components for qemu to boot up or test_start_qemu_terminal.sh failed.
	rc=$?	
	if [ $rc -ne 0 ]; then
        add_validate_error "test_start_qemu_terminal.sh should have exited with return value 0 but ended with rc=${rc} (rc 124=timeout)"
	fi
fi
