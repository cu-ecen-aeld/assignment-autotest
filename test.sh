#!/bin/bash
# Run an automated test against this repository
set -e
cd `dirname $0`
test_subdir=`mktemp`
workdir=`pwd`
# Copy the contents of the repository into test_subdir to
# simulate a proejct which adds this project as a submodule
rm -rf ${test_subdir}
mkdir -p ${test_subdir}
pushd ${test_subdir}
git init
git submodule add -f ${workdir}
# Copy the examples and parent-example cmake list files to
# the parent test_subdir directory.  Rename CMakeLists.txt so
# we will use this as our CMakeLists.txt file
cp -r assignment-autotest/examples .
cp assignment-autotest/CMakeLists-parent-example.txt ./CMakeLists.txt
# Create a build subdirectory, change into it, run
# cmake .. && make && run the assignment-autotest application
mkdir build
pushd build
cmake ..
make
./assignment-autotest/assignment-autotest
