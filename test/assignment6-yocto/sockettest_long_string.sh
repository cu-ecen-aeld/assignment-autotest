#!/bin/bash
# Tester script for Multithreaded server with periodic timestamp using Netcat
# Note: This script has to be executed only once after running the server
# Author : Steve Kennedy

target=localhost
port=9000
function printusage
{
	echo "Usage: $0 [-t target_ip] [-p port]"
	echo "	Runs a socket test on the aesdsocket application at"
	echo " 	target_ip and port specified by port"
	echo "	target_ip defaults to ${target}" 
	echo "	port defaults to ${port}" 
}

while getopts "t:p:" opt; do
	case ${opt} in
		t )
			target=$OPTARG
			;;
		p )
			port=$OPTARG
			;;
		\? )
			echo "Invalid option $OPTARG" 1>&2
			printusage
			exit 1
			;;
		: )
			echo "Invalid option $OPTARG requires an argument" 1>&2
			printusage
			exit 1
			;;
	esac
done

echo "Testing target ${target} on port ${port}"

# Tests to ensure socket send/receive is working properly on an aesdsocket utility
# running on the system
# @param1 : The string to send
# @param2 : The previous compare file
# @param3 : delay in seconds to test periodic timestamp
# Returns if the test passes, exits with error if the test fails.
function test_send_socket_string
{
	string=$1
	prev_file=$2
	
	new_file=`tempfile`
	file_wo_ts="tempfile_wo_ts.txt"

	expected_file=`tempfile`
	if [ "$string" = 'send_file' ]; then
		echo "sending a large test file"
		nc ${target} ${port} -w 1 < long_string.txt > ${new_file}

		grep -vwE "(timestamp)" ${new_file} > ${file_wo_ts}


		cp ${prev_file} ${expected_file}
		cat long_string.txt >> ${expected_file}

		
		
	else
		echo "sending string $string"
		echo ${string} | nc ${target} ${port} -w 1 > ${new_file}

		grep -vwE "(timestamp)" ${new_file} > ${file_wo_ts}

		cp ${prev_file} ${expected_file}
		echo ${string} >> ${expected_file}
		
	fi

	diff ${expected_file} ${file_wo_ts} > /dev/null
	if [ $? -ne 0 ]; then
		echo "Differences found after sending ${string} to ${target} on port ${port}"
		echo "Expected contents to match:"
		cat ${expected_file}
		echo "But found contents:"
		cat ${new_file}
		echo "With differences"
		diff -u ${expected_file} ${new_file}
		echo "Test complete with failure. Make sure you run this script before sending any data to server"
		exit 1

	else
		cp ${expected_file} ${prev_file}
		rm ${new_file}
		rm ${expected_file}		
		rm ${file_wo_ts}
		
	fi
}


comparefile=`tempfile`

test_send_socket_string "send_file" ${comparefile}

rm ${comparefile}

echo "Congrats! Test completed with success for long string"

