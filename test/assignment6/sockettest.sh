#!/bin/bash
# Tester script for Multithreaded server with periodic timestamp using Netcat
# Note: This script has to be executed only once after running the server
# Author : Steve Kennedy

target=localhost
port=9000
skip_long=
function printusage
{
	echo "Usage: $0 [-t target_ip] [-p port] [-s skip timing section]"
	echo "	Runs a socket test on the aesdsocket application at"
	echo " 	target_ip and port specified by port"
	echo "	target_ip defaults to ${target}" 
	echo "	port defaults to ${port}" 
}

while getopts "t:p:s" opt; do
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
	file_wo_ts=`tempfile`

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
		echo "Test complete with failure. Make sure you have restarted the socket server before starting this script"
		exit 1

	else
		cp ${expected_file} ${prev_file}
		rm ${new_file}
		rm ${expected_file}		
		rm ${file_wo_ts}
		
	fi
}

# Tests to ensure socket timer is working properly on an aesdsocket utility
# running on the system
# @param1 : delay in seconds to test periodic timestamp
# Returns if the test passes, exits with error if the test fails.
function test_socket_timer
{
	string="test_socket_timer"
	delay_secs=$1
	
	new_file=`tempfile`
	
	echo ${string} | nc ${target} ${port} -w 1 > ${new_file}

	cur_timestamp=$(grep -c "timestamp:" ${new_file})
	echo "No of timestamps currently in server file: ${cur_timestamp}"

	no_of_timestamps_during_delay=$((${delay_secs}/10))
	expected_timestamps=$((${cur_timestamp}+${no_of_timestamps_during_delay}))
	echo "No of timestamps expected after a delay of ${delay_secs} seconds is ${expected_timestamps}"

	sleep ${delay_secs}

	echo ${string} | nc ${target} ${port} -w 1 > ${new_file}
	verify_timestamps=$(grep -c "timestamp:" ${new_file})
	echo "No of timestamps found in file: ${verify_timestamps}"

	if [ ${verify_timestamps} -ge ${expected_timestamps} ]; then
		rm ${new_file}
	else
		echo "Differences found in the number of timestamps occurances"
		echo "Test complete with failure. Check your timer functionality"
		echo "The server returned:"
		cat ${new_file}
		exit 1	
	fi
}

string1="One best book is equal to a hundred good friends, but one good friend is equal to a library"
string2="If you want to shine like a sun, first burn like a sun"
string3="Never stop fighting until you arrive at your destined place - that is, the unique you"
process_send_count=3
# Delete the in progress temp files to signal to the main process that the child process
# has completed writing to the socket
thread1_in_progress=`mktemp`
thread2_in_progress=`mktemp`
thread3_in_progress=`mktemp`
function test_socket_thread1
{
	local c
	for (( c=1; c<=${process_send_count}; c++ ))
	do
		echo "Sending string ${string2} from process 1: instance ${c}"
		echo ${string1} | nc ${target} ${port} -w 1 > /dev/null
	done
	echo "Process 1 complete"
	rm $thread1_in_progress
}

function test_socket_thread2
{	
	local c
	for (( c=1; c<=${process_send_count}; c++ ))
	do
		echo "Sending string ${string2} from process 2: instance ${c}"
		echo ${string2} | nc ${target} ${port} -w 1 > /dev/null
	done
	echo "Process 2 complete"
	rm $thread2_in_progress
}

function test_socket_thread3
{
	local c
	for (( c=1; c<=${process_send_count}; c++ ))
	do
		echo "Sending string ${string3} from process 3: instance ${c}"
		echo ${string3} | nc ${target} ${port} -w 1  > /dev/null
	done
	echo "Process 3 complete"
	rm $thread3_in_progress
}

# Tests to ensure socket multithreaded send/receive is working properly on an aesdsocket utility
function validate_multithreaded
{
	echo "Waiting for sends to compete on all processes" 
	while [  -f ${thread1_in_progress} -o -f ${thread2_in_progress} -o -f ${thread3_in_progress} ]; do
		sleep 1
	done

	string="validate_multithreaded"	
	new_file=`tempfile`
	# Write a new string to the socket server, so it will return all data sent from other processes along
	# with this string
	echo ${string} | nc ${target} ${port} -w 1 > ${new_file}

	count_thread1=$(grep -o "$string1" ${new_file} | wc -l)
	count_thread2=$(grep -o "$string2" ${new_file} | wc -l)
	count_thread3=$(grep -o "$string3" ${new_file} | wc -l)

	if [ ${count_thread1} -eq ${process_send_count} ] && [ ${count_thread2} -eq ${process_send_count} ] && [ ${count_thread3} -eq ${process_send_count} ]; then
		echo "multithreaded test complete with success"	
	else
		if [ ${count_thread1} -ne ${process_send_count} ]; then
			echo "Found $count_thread1 instance of string -> $string1 in ${new_file} "
			echo "But expected ${process_send_count} instances"
		fi

		if [ ${count_thread2} -ne ${process_send_count} ]; then
			echo "Found $count_thread2 instance of string -> $string2 in ${new_file} "
			echo "But expected ${process_send_count} instances"
		fi

		if [ ${count_thread3} -ne ${process_send_count}  ]; then
			echo "Found $count_thread3 instance of string -> $string3 in ${new_file} "
			echo "But expected ${process_send_count} instances"
		fi

		echo "Test complete with failure. Check your locking mechanism"
		echo "The server returned:"
		cat ${new_file}
		exit 1
	fi

}

comparefile=`tempfile`

test_send_socket_string "abcdefg" ${comparefile}
test_send_socket_string "hijklmnop" ${comparefile}
test_send_socket_string "1234567890" ${comparefile}
test_send_socket_string "9876543210" ${comparefile}

echo

echo "Spawning three processes to ensure multithreaded writes work as expected"
echo "Process 1 writes ${string1}"
echo "Process 2 writes ${string2}"
echo "Process 3 writes ${string3}"

test_socket_thread1&
test_socket_thread2&
test_socket_thread3&

validate_multithreaded

rm ${comparefile}
echo ""
echo "Testing the timer functionality"

test_socket_timer 21


echo "Congrats! Tests completed with success"
exit 0
