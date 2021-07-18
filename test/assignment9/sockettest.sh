#!/bin/bash
# Tester script for sockets using Netcat

target=localhost
port=9000
rc=0
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

check_output()
{
	local read_file=$1
	local expected_file=$2
	diff ${read_file} ${expected_file}
	if [ $? -ne 0 ]; then
		echo "difference detected, expected:"
		cat ${expected_file}
		echo "but found"
		cat ${read_file}
		rc=-1
	fi
}
function send_socket_string
{
	string=$1
	result_file=$2
	echo ${string} | nc ${target} ${port} -w 1 > ${result_file}
}
# Tests to ensure socket send/receive is working properly on an aesdsocket utility
# running on the system
# @param1 : The string to send
# @param2 : The previous compare file
# Returns if the test passes, exits with error if the test fails.
function test_send_socket_string
{
	string=$1
	prev_file=$2
	new_file=`tempfile`
	expected_file=`tempfile`
	send_socket_string ${string} ${new_file}
	cp ${prev_file} ${expected_file}
	echo ${string} >> ${expected_file}
	diff ${expected_file} ${new_file} > /dev/null
	if [ $? -ne 0 ]; then
		echo "Differences found after sending ${string} to ${target} on port ${port}"
		echo "Expected contents to match:"
		cat ${expected_file}
		echo "But found contents:"
		cat ${new_file}
		echo "With differences"
		diff -u ${expected_file} ${new_file}
		echo "Test complete with failure"
		exit 1
	else
		cp ${expected_file} ${prev_file}
		rm ${new_file}
		rm ${expected_file}
	fi
}

comparefile=`tempfile`
test_send_socket_string "swrite1" ${comparefile}
test_send_socket_string "swrite2" ${comparefile}
test_send_socket_string "swrite3" ${comparefile}
test_send_socket_string "swrite4" ${comparefile}
test_send_socket_string "swrite5" ${comparefile}
test_send_socket_string "swrite6" ${comparefile}
test_send_socket_string "swrite7" ${comparefile}
test_send_socket_string "swrite8" ${comparefile}
test_send_socket_string "swrite9" ${comparefile}
test_send_socket_string "swrite10" ${comparefile}

seek_result=`tempfile`
echo "Sending ioc seekto command for offset 0,2"
send_socket_string "AESDCHAR_IOCSEEKTO:0,2"  ${seek_result}
cat ${seek_result}
cat > ${comparefile}  << EOF
rite1
swrite2
swrite3
swrite4
swrite5
swrite6
swrite7
swrite8
swrite9
swrite10
EOF

check_output ${seek_result} ${comparefile}


echo "Sending ioc seekto command for offset 8,6"
send_socket_string "AESDCHAR_IOCSEEKTO:8,6"  ${seek_result}
cat ${seek_result}

cat > ${comparefile}  << EOF
9
swrite10
EOF


check_output ${seek_result} ${comparefile}

if [ ${rc} -eq 0 ]; then
	echo "Test passed"
fi
exit ${rc}
