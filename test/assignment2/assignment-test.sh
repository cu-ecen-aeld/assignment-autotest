#!/bin/sh
# First parameter, if specified

cd `dirname $0`
. ./script-helpers
. ./assignment-1-test-iteration.sh

cd ../../../

# --------------------------------------------------#
# Checks to validate Cross Compilation
#create a file name arm-unknown-linux-gnueabi-gcc
echo "creating a file named arm-unknown-linux-gnueabi-gcc"
touch arm-unknown-linux-gnueabi-gcc
chmod 777 arm-unknown-linux-gnueabi-gcc

#Writing contents to arm-unknown-linux-gnueabi-gcc
#A file named validation.txt will be created if arm-unknown-linux-gnueabi-gcc is invoked
echo "#!/bin/sh">> arm-unknown-linux-gnueabi-gcc
echo "touch validation.txt" >> arm-unknown-linux-gnueabi-gcc

#set the compiler path to arm-unknown-linux-gnueabi-gcc created
export PATH=$PATH:$(pwd)

make clean
make CROSS_COMPILE=arm-unknown-linux-gnueabi-

#check if cross compiling was successful
file="validation.txt"
if [ ! -f "$file" ]
then
	add_validate_error "Error in cross compiling of make file"
else
	#remove the temporary file if created
	rm validation.txt
fi

#removing the temporaryly created files
echo "removing file arm-unknown-linux-gnueabi-gcc"
rm arm-unknown-linux-gnueabi-gcc

make clean

make

# ------------------------------------------------- #
filesdir=/tmp/aesd-data
numfiles=10
writestr="AESD_IS_AWESOME"
username=$(cat conf/username.txt)

./writer

rc=$?
if [ $rc -ne 1 ]; then
	add_validate_error "writer.sh should have exited with return value 1 if no parameters were specified"
fi


./writer "$filedir"
rc=$?
if [ $rc -ne 1 ]; then
	add_validate_error "writer.sh should have exited with return value 1 if write string is not specified"
fi

./tester.sh
rc=$?
if [ $rc -ne 0 ]; then
	add_validate_error "tester.sh execution failed with return code $rc"
fi

assignment_1_test_validation ${filesdir} ${numfiles} ${writestr} ${username}

rm -rf ${filesdir}

RANDOM=`hexdump -n 2 -e '/2 "%u"' /dev/urandom`
numfiles=$(( ${RANDOM} % 100 ))
randomstring=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '')
writestr="Random_char_string${randomstring}"

./tester.sh ${numfiles} ${writestr}
assignment_1_test_validation ${filesdir} ${numfiles} ${writestr} ${username}

if [ -z "${validate_error}" ]; then
    exit 0
else
    echo "Test failed with error : ${validate_error}"
    exit 1
fi
