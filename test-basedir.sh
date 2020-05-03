#!/bin/bash
# Test the example implementation, running against either a directory
# specified as argument, or a temp directory created
set -e
pushd `dirname $0`
# Create a build subdirectory, change into it, run
# cmake .. && make && run the assignment-autotest application
mkdir -p build
pushd build
cmake ..
make
./assignment-autotest/assignment-autotest
echo "Test complete with success"
