#!/bin/bash
# Run unit tests for the assignment

# Automate these steps from the readme:
# Create a build subdirectory, change into it, run
# cmake .. && make && run the assignment-autotest application
mkdir -p build
cd build

cmake ..
if [[ $? -ne 0 ]]; then echo "cmake failed"; exit 1; fi

make clean
if [[ $? -ne 0 ]]; then echo "make clean failed"; exit 1; fi

make
if [[ $? -ne 0 ]]; then echo "make failed"; exit 1; fi

cd ..
./build/assignment-autotest/assignment-autotest
