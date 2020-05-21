# Assignment Testing Scripts

The scripts under this directory are useful for pulling down student assignments and running tests against them.

An overview of scripts and usage is found below

# Installing Docker

The assignment testing steps require Docker Community Edition.  See install instructions [here](https://docs.docker.com/install/linux/docker-ce/ubuntu/) for ubuntu


## github-classroom-scripts and scripts_config

These are the github classroom scripts useful for pulling files from github classroom and creating pull requests for
submissions.  See [https://github.com/dwalkes/github-classroom-scripts](https://github.com/dwalkes/github-classroom-scripts)
for more detail.

## testall.sh
Kick off tests of all student repository submissions using github classroom scripts.  This is the command which should
be run after the due date to test all assignment repositories.  This script supports additional arguments passed to `prsetup.py`,
for instance to specify running against a single student repository.

Each student's submission will be checked out to a directory under `~/pr-script-clone` and a log file containing results of the
submission can be found in the `~/test_script_results/` directory.

To grep for students whose assignment failed testing, you can use a command like:

`grep "Exiting with failure" ~/test_script_results/*assignmentX_*.log` substituting the 'X' with the assignment number.  Use
a similar search to look for the number of students who failed with specific failure types


## assignment-testing

This directory contains scripts used to test assignments.  An overview of each script and its usage is listed below

### do-test

This is the main test entry script, called from github-classroom-scripts/pr-setup.py with parameter pointing to the location
where the student's code is located.  When called with no arguments, it runs tests on the local repository.  This is useful
for test purposes when validating tests are succesful against checked in code implementations in the solution repository.

### do-docker-test

This script is called from `do-test`.  It creates a docker container used to run the student's test code based on the Dockerfile
setup for the assignment, then calls `do-test-local`.  Running tests in isolation limits student code from accessing anything running
on the host, and ensures each student has an identical run environment.

### do-test-local

This script is called to run local tests against assignment code inside the docker container, and dump out all validation failures.

### script-helpers

This script is sourced from assignment test scripts, and contains common utility functions shared across multiple assignments.  The
most useful is probably `add_validate_error` which acceps a string describing the error condition and sets a variable trackign the fact
that at least one validation error has failed during the test.

### assignment-test.sh

This is a symlink to the appropriate assignment test script for each assignment, and should change based on the assignment associated
with the code in respective branches of the assignment solution repository.

The assignment test script is passed an argument containing the path to the assignment source code.  It should run any validation commands
for the current assignment, tracking validation errors with `add_validate_error`.

## Assignment Testing Workflow

This section describes the workflow which can be used by student assistants to develop tests for specific assignments.

Start by checking out an assignment completion branch, merging with the previous assignment completion branch to pull in any changes to shared
test scripts, then updating the assignment-x-test.sh script, ensuring the assignment-test.sh symlink is pointed to this script.

When working in an assigment completion branch, you can start by running `do-test-local.sh` with no arguments to run against the local script content.

Once this passes, you can use `do-test.sh` to run in a docker container as a student repository would be tested.

When troubleshooting a failed student submission repo you can run
`./assignment-testing/do-test ~/pr-script-clone/<student_repo_path>` to run the assignment test script in isolation for this student.
You can also run
`./assignment-testing/do-test-local ~/pr-script-clone/<student_repo_path>` if you want to run outside the docker container, however keep in mind this should
only be run after you are convinced the student's submission doesn't do anything dangerous or milicious such as deleting system content or copying unauthorized
resources.

