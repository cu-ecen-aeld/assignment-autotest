#!/bin/sh

. ./script-helpers

assignment_1_test_validation() {
	filesdir=$1
	numfiles=$2
	writestr=$3
	username=$4
	curr_day=$(date '+%d')
	curr_month=$(date '+%m')
	curr_year=$(date '+%Y')
	
	files_list=$(find ${filesdir} -name "${username}*.txt")
	files_created=$(echo "${files_list}" | wc -l)

	if [ ${files_created} -ne ${numfiles} ]; then
		add_validate_error "expected ${numfiles} created by ./tester.sh in ${filesdir} but found ${files_created} with files list ${files_list}"
	fi
	
	for i in $( seq 1 $numfiles)
	do
		act_date=$(tail "${filesdir}/${username}${i}.txt" -n 1)
		act_day=$(date --date="$act_date" "+%d")
		act_month=$(date --date="$act_date" "+%m")
		act_year=$(date --date="$act_year" "+%Y")

		if [ "${curr_day}" != "${act_day}" ]; then 
			add_validate_error "expected date ${curr_day} but found $(act_day))"
			break
		fi
		if [ "${curr_month}" != "${act_month}" ]; then 
			add_validate_error "expected month ${curr_month} but found $(act_month))"
			break
		fi
		if [ "${curr_year}" != "${act_year}" ]; then 
			add_validate_error "expected year ${curr_year} but found $(act_year))"
			break
		fi
	done

	for file in $files_list
	do
		grep "${githubstudent}" ${file}
		if [ $? -ne 0 ]; then
			add_validate_error "expected Github username ${githubstudent} in ${file} but found no match"
			break
		fi
	done

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