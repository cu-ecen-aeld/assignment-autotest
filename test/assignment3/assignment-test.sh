#!/bin/bash
pushd $(dirname $0)
source script-helpers

SCRIPTS_DIR=$(pwd)
OUTDIR=/tmp/aesd-autograder
SOURCE_DIR=$(realpath ${SCRIPTS_DIR}/../../../)

# Invoke docker script with --env SKIP_BUILD=1 --env DO_VALIDATE=1 to perform a validation only
# test
echo "starting test with SKIP_BUILD ${SKIP_BUILD} and DO_VALIDATE ${DO_VALIDATE}"
if [[ -z ${SKIP_BUILD} || ${SKIP_BUILD} -eq 0 ]]; then
    pushd ${SOURCE_DIR}/finder-app
    ./manual-linux.sh ${OUTDIR}
	rc=$?
	if [ $rc -ne 0 ]; then
		add_validate_error "manual-linux script failed with ${rc}"
	fi
    popd
fi

if [[ -z ${DO_VALIDATE} || ${DO_VALIDATE} -eq 1 ]]; then
    qemu_timeout=60
    logfile=${OUTDIR}/serial.log
    pushd ${SOURCE_DIR}/finder-app
    rm -f ${logfile}
    touch ${logfile}
    echo "Kick off qemu in the background"
    ./start-qemu-app.sh ${OUTDIR} &
    echo "Wait for app to finish"
    # See https://stackoverflow.com/a/6456103
    timeout ${qemu_timeout} grep -q "finder-app execution complete" <(tail -f ${logfile})
    rc=$?
    if [ $rc -ne 0 ]; then
        add_validate_error "Running finder application on qemu failed with return code $rc, see ${logfile} for details"
        if [ $rc -eq 124 ]; then
            add_validate_error "Application timed out waiting ${qemu_timeout} seconds for finder app execution to complete"
        fi
    fi
    killall qemu-system-aarch64
    popd
fi

if [ ! -z "${validate_error}" ]; then
    echo "Validation failed with error list ${validate_error}"
    exit 1
fi
