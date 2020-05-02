#!/bin/bash
# Test the example implementation, running against either a directory
# specified as argument, or a temp directory created
set -e
if [ $# -eq 1 ]; then
    work_dir=$1
    work_dir=$(realpath ${work_dir})
else
    work_dir=`mktemp -d`
fi
pushd `dirname $0`
mkdir -p ${work_dir}
autotest_sourcedir=`pwd`
# Copy the contents of the repository into work_dir to
# simulate a proejct which adds this project as a submodule
pushd ${work_dir}
if [ ! -f ${work_dir}/.git ]; then
    git init
fi
git submodule add -f ${autotest_sourcedir}
git submodule update --init --recursive
# Copy the examples and parent-example cmake list files to
# the parent work_dir directory.  Rename CMakeLists.txt so
# we will use this as our CMakeLists.txt file
cp -r assignment-autotest/examples .
cp assignment-autotest/CMakeLists-parent-example.txt ./CMakeLists.txt
# Create a build subdirectory, change into it, run
# cmake .. && make && run the assignment-autotest application
mkdir -p build
pushd build
cmake ..
make
./assignment-autotest/assignment-autotest
echo "Test success, working example in ${work_dir}"
