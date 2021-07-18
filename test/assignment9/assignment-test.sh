#!/bin/bash
# 1st argument: absolute or relative path to the base directory
# Defaults to dirname `git rev-parse --absolute-git-dir` if not specified

echo "STEPS TO MANUALLY TEST ASSIGNMENT 9 on your native machine"
echo "These steps are useful for debugging your application before attempting to run on"
echo "an embedded target"

echo "After following assignment implementation steps"
echo "cd into your aesd-char-driver DIRECTORY and do a make to build for your development machine."
echo "RUN ./aesdchar_unload, followed by ./aesdchar_load to load your module on your development machine"
echo "From your main root assignment directory,"
echo "RUN ./assignment-autotest/test/assignment9/drivertest.sh to verify you implementation"

echo "When drivertest succeeds, start your modified aesdsocket application from the server subdirectory"
echo "Verify it passes sockettest.sh by running ./assignment-autotest/test/assignment9/sockettest.sh"
