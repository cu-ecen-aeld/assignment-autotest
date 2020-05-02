# assignment-autotest
A repository which can be used for autotest of assignments, leveraging the [Unity](https://github.com/ThrowTheSwitch/Unity)
automated test framework.

This project is a [CMake](https://cmake.org/) and script wrapper around [Unity](https://github.com/ThrowTheSwitch/Unity) which allows:
 * Test dependencies to be included as a git submodule on student assignment repositories.
 * Instructors can define functions containing tests they expect to pass on completed student submissions, which
    can be shared with students through this repository in the test subfolder.
 * Instructors to define functions containing tests that will not be shared with students but which should also
    pass on student's final submission.
 * Students can define their own test functions/files they use to test their code.

See the [Unity](https://github.com/ThrowTheSwitch/Unity) refernece documentation for information about writing
Unity test cases.

## Using This Repository

Follow the instructions in this section to setup your source code repository with assignment t

### Setting Up Your Host

1. Install ruby on your host. This is used to [run unity helper scripts](https://github.com/ThrowTheSwitch/Unity/blob/master/docs/UnityHelperScriptsGuide.md) used to generate test runner files.  
2. Install cmake on your host.

On Ubuntu the above two steps can be completed with `sudo apt-get install -y ruby cmake`.


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

### Running Tests
Use cmake to build your parent project using something like:
`mkdir build && cd build` then `cmake .. && make`

Then run `./assignment-autotest/assignment-autotest` from within the build directory to

### Running An Example
To see an example implementation in action, run the `./test.sh` script, passing in an argument to a directory subfolder on the host.  If
the directory does not correspond to an existing git repository a git repository will be initialized there, then the steps to clone the
repository as a submodule, add example tests, and run tests will be done automatically.
