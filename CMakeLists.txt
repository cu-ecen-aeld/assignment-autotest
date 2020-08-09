# To use this cmake script 
# 1) Create your own CMakeLists.txt which uses add_subdirectory to specify the location of this file
#      (typically assignment-autotest if you've added this repository as a submodule.
# 2) Define variables
#       - TESTED_SOURCE with relative paths to source code (.c) files to be tested.
#       - AUTOTEST_SOURCES with relative paths to source code containing unity based test source, which
#           may reference test subfolders within this project for specific assignments or files outside
#           this repository defined by students as a part of their submission.  Relative paths should be
#           specified relative to the root directory of the aassignment-autotest repository.
# 3) Define project name with something like project(assignment-autotest)
# The generated "assignment-autotest" application will run all tests defined in each AUTOTEST_SOURCES file

cmake_minimum_required(VERSION 3.0.0)
project(assignment-autotest)
# Include unity testing
add_subdirectory(Unity)
include_directories(Unity/src . ..)
foreach(AUTOTEST_SOURCE ${AUTOTEST_SOURCES})
    string(REGEX REPLACE "(.+Test_[^.]+).c" "${CMAKE_CURRENT_SOURCE_DIR}/\\1_Runner.c" RUNNER_SOURCE ${AUTOTEST_SOURCE})
    set(RUNNER_SOURCES "${RUNNER_SOURCES};${RUNNER_SOURCE}")
endforeach()
MESSAGE(STATUS "Generating ${RUNNER_SOURCES} from ${AUTOTEST_SOURCES}")
MESSAGE(STATUS "Building executable including ${RUNNER_SOURCES} ${AUTOTEST_SOURCES} and ${TESTED_SOURCE}")
add_executable(assignment-autotest ${AUTOTEST_SOURCES} ${RUNNER_SOURCES} ${TESTED_SOURCE} ${CMAKE_CURRENT_SOURCE_DIR}/test/unity_runner.c)
target_link_libraries(assignment-autotest unity)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Werror")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Werror")
# See https://cmake.org/cmake/help/latest/command/add_custom_command.html
# Generate our test runner using the auto_generate.sh script
add_custom_command(OUTPUT ${RUNNER_SOURCES} ${CMAKE_CURRENT_SOURCE_DIR}/test/unity_runner.c
                   COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/auto_generate.sh ${AUTOTEST_SOURCES}
                   DEPENDS ${AUTOTEST_SOURCES}
                )
set(CMAKE_BUILD_TYPE Debug)
