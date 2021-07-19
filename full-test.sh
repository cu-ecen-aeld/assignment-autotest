#!/bin/sh
# Test the example implementation, running against either a directory
# specified as argument, or a temp directory created
set -e
if [ $# -eq 1 ]; then
    work_dir=$1
    work_dir=$(realpath ${work_dir})
else
    work_dir=`mktemp -d`
fi
cd `dirname $0`
mkdir -p ${work_dir}
autotest_sourcedir=`pwd`
# Copy the contents of the repository into work_dir to
# simulate a proejct which adds this project as a submodule
cd ${work_dir}
if [ ! -f ${work_dir}/.git ]; then
    git init
fi
git submodule add -f ${autotest_sourcedir} assignment-autotest
git submodule update --init --recursive
# Copy the examples and parent-example cmake list files to
# the parent work_dir directory.  Rename CMakeLists.txt so
# we will use this as our CMakeLists.txt file
# Copy the travis file to the base directory so it will support
# Travis CI and rename it test.sh
cp -r assignment-autotest/examples .
cp assignment-autotest/CMakeLists-parent-example.txt ./CMakeLists.txt
cp assignment-autotest/test-basedir.sh full-test.sh
cp assignment-autotest/test-unit.sh .
# Run the test script (test-basedir.sh renamed) in the base directory,
# Same as it will be run from Travis-CI
./full-test.sh
echo "Test success, working example in ${work_dir}"
