#!/bin/sh
# Test script used to test assignment 9 char driver with seek implementation

rc=0
device=/dev/aesdchar

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

read_with_seek()
{
	local seek=$1
	local device=$2
	local read_file=$3
	dd if=${device} skip=${seek} of=${read_file} bs=1 > /dev/null 2>&1
}

echo "write1" > ${device}
echo "write2" > ${device}
echo "write3" > ${device}
echo "write4" > ${device}
echo "write5" > ${device}
echo "write6" > ${device}
echo "write7" > ${device}
echo "write8" > ${device}
echo "write9" > ${device}
echo "write10" > ${device}



read_file=$(mktemp)
expected_file=$(mktemp)

read_with_seek 2 ${device} ${read_file}

cat > ${expected_file}  << EOF
ite1
write2
write3
write4
write5
write6
write7
write8
write9
write10
EOF


echo "The output below should show write 1 with first 2 bytes missing"
cat ${read_file}

check_output ${read_file} ${expected_file}

read_with_seek 61 ${device} ${read_file}

cat > ${expected_file}  << EOF
9
write10
EOF


echo "The output below should show the 9 from write 9 followed by write10 only"
cat ${read_file}

check_output ${read_file} ${expected_file}


exit ${rc}
