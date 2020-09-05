#!/bin/bash
# A script to auto generate test runners for unity tests
cd `dirname $0`
set -e
pushd ..
mkdir -p test/test_runners
# See https://github.com/ThrowTheSwitch/Unity/blob/master/docs/UnityHelperScriptsGuide.md
ruby Unity/auto/generate_test_runner.rb test/Test_circular_buffer.c test/test_runners/Test_circular_buffer_Runner.c
