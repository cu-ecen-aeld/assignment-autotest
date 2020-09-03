#!/bin/bash
cd `dirname $0`
source script-helpers
pushd $1

#Setup unity test framework.
cd aesd-char-driver
git submodule init 
git submodule update

rm -rf build
mkdir -p build 
cd build
cmake ..

cd ..
./run-unittest.sh >> result.txt

cat result.txt | grep "1 Tests 0 Failures 0 Ignored"
if [ $? -ne 0 ]; then
	add_validate_error "Unity test fail !!! Check logs."
	cat result.txt | tail -n 11
fi

rm -f result.txt


