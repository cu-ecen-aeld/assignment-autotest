#!/bin/sh

. ./script-helpers

assignment_1_test_validation() {
	filesdir=$1
	numfiles=$2
	writestr=$3
	username=$4

    ./tester.sh ${numfiles} ${writestr}
    
    if [ $? -ne 0 ]; then
        add_validate_error "Expected zero success return from tester script"
    fi

	files_list=$(find ${filesdir} -name "${username}*.txt")
	files_created=$(echo "${files_list}" | wc -l)

	if [ ${files_created} -ne ${numfiles} ]; then
		add_validate_error "expected ${numfiles} files created by ./tester.sh matching ${username}*.txt pattern within ${filesdir} but found ${files_created} with files list ${files_list}"
	fi
	
	./finder.sh

	if [ $? -ne 1 ]; then
		add_validate_error "finder.sh should have exited with return value 1 if no parameters were specified"
	fi

	./finder.sh /tmp

	if [ $? -ne 1 ]; then
		add_validate_error "finder.sh should have exited with return value 1 if search string was not specified"
	fi

	./finder.sh /non-exist-path "search"

	if [ $? -ne 1 ]; then
		add_validate_error "finder.sh should have exited with return value 1 if a non-existent path was specified"
	fi

	output=$(./finder.sh ${filesdir} ${writestr})

	echo ${output} | grep "number of files are ${numfiles}"

	if [ $? -ne 0 ]; then
		add_validate_error "Expected to find number of files listed as ${numfiles} by finder script, found ${output}"
	fi

	echo ${output} | grep "number of matching lines are ${numfiles}"
	if [ $? -ne 0 ]; then
		add_validate_error "Expected to find number of matching lines listed as ${numfiles} by finder script, found ${output}"
	fi
}
