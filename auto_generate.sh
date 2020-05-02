#!/bin/bash
# A script to auto generate test runners for unity tests and a single test/unity_runner.c
# file which combines all runners into a single executable
# Pass as arguments a list of test files for which we need to create runners
assignment_test_basedir_relative=`dirname $0`
assignment_test_basedir=$(realpath ${assignment_test_basedir_relative})
set -e
set +x
# Loop over each test file specified in the argument list
echo "Test files for auto dependency generation $@"
rm -f ${assignment_test_basedir}/test/unity_runner.c
mainfunc_content=
for test_file in $@; do
    file_dir=$(dirname $test_file)
    echo "Autogenerating runner for ${test_file}"
    filename=$(basename $test_file .c)
    # Create a ${test_file}_Runner used to run any tests defined in ${test_file}
    # See https://github.com/ThrowTheSwitch/Unity/blob/master/docs/UnityHelperScriptsGuide.md   
    # and supported arguments at https://github.com/ThrowTheSwitch/Unity/blob/master/auto/generate_test_runner.rb#L483
    # Define all function names so they don't conflict with each other
    # We'll make our own main() function to combine all of these together in unity_runner.c 
    ruby ${assignment_test_basedir}/Unity/auto/generate_test_runner.rb  ${assignment_test_basedir}/${test_file} \
        --setup_name="${filename}_setUp" \
        --teardown_name="${filename}_tearDown" \
        --main_name="${filename}_main" \
        --test_reset_name="${filename}_resetTest" \
        --test_verify_name="${filename}_verifyTest" \

    mainfunc_content="${mainfunc_content} rc=${filename}_main(); if (rc != 0) { return rc; } "
    setup_content="${filename}_setUp(); "
    teardown_content="${filename}_tearDown(); "
    extern_content="${extern_content} extern int ${filename}_main(void); extern void ${filename}_tearDown(); extern void ${filename}_setUp();"
done
echo "Autogenerating test/unity_runner.c"
cat << EOF > ${assignment_test_basedir}/test/unity_runner.c
${extern_content}
void setUp(void) { ${setup_content} }
void tearDown(void) { ${teardown_content} }
int main(int argc, char **argv) { int rc=0; ${mainfunc_content} }
EOF
