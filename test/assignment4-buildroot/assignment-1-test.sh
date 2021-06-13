#!/bin/sh

cd `dirname $0`

filesdir=/tmp/aesd-data
numfiles=20
writestr="AESD_IS_AWESOME"

writer
rc=$?
if [ $rc -ne 1 ]; then
        add_validate_error "writer.sh should have exited with return value 1 if no parameters were specified"
fi

writer "$filedir"
rc=$?
if [ $rc -ne 1 ]; then
        add_validate_error "writer.sh should have exited with return value 1 if write string is not specified"
fi

finder-test.sh
rc=$?
if [ $rc -ne 0 ]; then
        add_validate_error "tester.sh execution failed with return code $rc"
fi

rm -rf ${filesdir}
