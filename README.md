# Github Actions Status
[![Build Status](https://github.com/cu-ecen-aeld/assignment-autotest/actions/workflows/github-actions.yml/badge.svg)

    
# assignment-autotest
A repository which can be used for autotest of assignments, leveraging the [Unity](https://github.com/ThrowTheSwitch/Unity)
automated test framework.

This project is a [CMake](https://cmake.org/) and script wrapper around [Unity](https://github.com/ThrowTheSwitch/Unity) which allows:
 * Test dependencies to be included as a git submodule on student assignment repositories.
 * Instructors can define functions containing tests they expect to pass on completed student submissions, which
    can be shared with students through this repository in the test subfolder.
 * Instructors can define files containing tests that will *not* be shared with students but which should also
    pass on student's final submission.  These will be located in the parent repository containing this repository as a submodule.
 * Students can define their own test functions/files they use to test their code in their own repositories, referencing this repository
    as a submodule.
 * Other tests which aren't unity based can also be located in the appropriate test/assignment subdirectory and included with automated tests

See the [Unity](https://github.com/ThrowTheSwitch/Unity) reference documentation for information about writing
Unity test cases.

## Using This Repository

Follow the instructions in this section to setup your source code repository with assignments.

### Setting Up Your Host

1. Install `build-essential` or equivalent on non-ubuntu platforms (gcc, g++, make).
2. Install ruby on your host. This is used to [run unity helper scripts](https://github.com/ThrowTheSwitch/Unity/blob/master/docs/UnityHelperScriptsGuide.md) used to generate test runner files.
3. Install cmake on your host.

On Ubuntu the above steps can be completed with `sudo apt-get install -y build-essential ruby cmake`.


### Clone this repository as a submodule

Inside your existing git repository containing assignment example source code or completed assignment implementations,
use `git submodule add` to add this repository as a submodule.

Then use `git submodule update --init --recursive` to initialize the Unity submodule referenced within this repository.

### Add Example Tests

Add your example test files for students which show how they can specify and add unit tests. Unit Tests are added through
a CMakeLists.txt file at the root of your repository which sets cmake variables referencing:
 * The files containing test_XXXX functions which use unity to unit test application source
 * The files containing application source code to be unit tested.

Refer to the comments in the [CMakeLists-parent-example.txt](CMakeLists-parent-example.txt) for variable usage instructions

A simple example is shown in the [examples](examples) subdirectory, [CMakeLists-parent-example.txt](CMakeLists-parent-example.txt)
file, and [test/assignment1](test/assignment1) subdirectory.

### Update your gitignore
Include these patterns in your root .gitignore file
```
Test_*_Runner.c
build/
```

### Running Tests
Use cmake to build your parent project using something like:
`mkdir build && cd build` then `cmake .. && make && cd ..`

Then run `build/assignment-autotest/assignment-autotest` from within the build directory to run the Unity based automated tests.

You can run only the unity based automated tests using the `test-unit.sh` script.

You can add additional tests to cover other assignment requirements in the [test](test) directory, and use logic in your
./test.sh test script to pull them in.

These steps are automated in the `test-basedir.sh` script which you can copy into your base repository directory and use
as a template example

### CI Integration

#### Github Actions
If you can add automated CI testing to your base
repo by following these steps.

1. Copy the `test-basedir.sh` script to the repository containing this submodule and rename `./test.sh`
2. Copy the `.github` directory to the base directory of the repository containing this submodule and customize the
    `workflow/github-actions.yml` file to perform testing for your implementation.
3. If desired, [add a badge](https://docs.github.com/en/actions/managing-workflow-runs/adding-a-workflow-status-badge) to your README.md showing build status.  See the line at the top of this README.md for an example.


### Running An Example
To see an example implementation in action, run the `./test.sh` script, passing in an argument to a directory subfolder on the host.  If
the directory does not correspond to an existing git repository a git repository will be initialized there, then the steps to clone the
repository as a submodule, add example tests, and run tests will be done automatically.  If no argument is specified, the example will be demonstrated in a temporary directory created on the host.

#### Running Example Using Docker

Running tests in Docker is a useful step to simulate the behavior on the CI build system.  This is especially true for gitlab-ci builds since these
are configured to use the same image.

Start by setting up docker community edition on your host.  See install instructions [here](https://docs.docker.com/install/linux/docker-ce/ubuntu/) for Ubuntu.

You can run test in a docker container using the [docker/run-test.sh](docker/run-test.sh) script. This script is currently
setup to use the same image used for gitlab-ci testing, [cuaesd/aesd-autotest](https://hub.docker.com/repository/docker/cuaesd/aesd-autotest) but could be customized to use
any docker container suitable for your assignments. 

Run from any base directory containing a `test.sh` script.  The script will start the docker container, pass through the base directory as a volume, change user/group ID
of the user in the container to match the caller (to avoid permission issues with builds outside the container), and then run the test script.
