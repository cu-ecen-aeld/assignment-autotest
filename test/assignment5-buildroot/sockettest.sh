# !/bin/bash
# Tester script for sockets using Netcat

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
		h )
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
# Returns if the test passes, exits with error if the test fails.
function test_send_socket_string
{
	string=$1
	prev_file=$2
	new_file=`tempfile`
	expected_file=`tempfile`
	echo ${string} | nc ${target} ${port} -w 1 > ${new_file}
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
test_send_socket_string "abcdefg" ${comparefile}
test_send_socket_string "hijklmnop" ${comparefile}
test_send_socket_string "1234567890" ${comparefile}
test_send_socket_string "9876543210" ${comparefile}
echo "Tests complete with success, last response from server was"
cat ${comparefile}
rm ${comparefile}
