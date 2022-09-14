#include "unity.h"
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include "../../../examples/systemcalls/systemcalls.h"
#include "file_write_commands.h"

/**
* This function should:
*   1) Call the do_system() function in systemcalls.c to perform the system() operation.
*   2) Obtain the value returned from return_string_validation() in file_write_commands.h within
*       the assignment autotest submodule at assignment-autotest/test/assignment3/
*   3) Use unity assertion TEST_ASSERT_EQUAL_STRING_MESSAGE the two strings are equal.  See
*       the [unity assertion reference](https://github.com/ThrowTheSwitch/Unity/blob/master/docs/UnityAssertionsReference.md)
*   4) Test with strncmp fo string which return the full path for $HOME,
*       and compare the value using TEST_ASSERT_EQUAL_INT16_MESSAGE.
*   5) Call the do_exec() function in systemcalls.c to perform fork(), execv() and wait() instead of using the system() command.
*   6) Test for a true and false message on the above commands using TEST_ASSERT_FALSE_MESSAGE(TRUE_MESSAGE).
*   7) Call the do_exec_redirect() function in systemcalls.c to perform the same operation as do_exec(),
*       but redirect ouptut to standard out.
*   8) Obtain the value returned from return_string_validation() in file_write_commands.h within
*       the assignment autotest submodule at assignment-autotest/test/assignment3/
*   9) Use unity assertion TEST_ASSERT_EQUAL_STRING_MESSAGE the two strings are equal.
*
**/
#define REDIRECT_FILE "testfile.txt"

void test_systemcalls()
{

    printf("Running tests at %s : function %s\n",__FILE__,__func__);
    TEST_ASSERT_TRUE_MESSAGE(do_system("echo this is a test > " REDIRECT_FILE ),
            "do_system call should return true running echo command");
    char *test_string = malloc_first_line_of_file(REDIRECT_FILE);
    printf("system() echo this is a test returned %s\n", test_string);
    // Testing implementation with testfile.txt output 
    TEST_ASSERT_EQUAL_STRING_MESSAGE("this is a test", test_string,
            "Did not find \"this is a test\" in output of echo command." 
            " Is your system() function implemented properly?");
    free((void *)test_string);
    
    TEST_ASSERT_TRUE_MESSAGE(do_system("echo \"home is $HOME\" > " REDIRECT_FILE),
             "do_system call should return true running echo command");
    test_string = malloc_first_line_of_file(REDIRECT_FILE);
    int test_value = strncmp(test_string, "home is /", 9);
    printf("system() echo home is $HOME returned: %s\n", test_string);
    // Testing implementation with testfile.txt output 
    TEST_ASSERT_EQUAL_INT16_MESSAGE(test_value, 0,
            "The first 9 chars echoed should be \"home is /\".  The last chars will include "
            "the content of the $HOME variable");
    test_value = strncmp(test_string, "home is $HOME", 9);
    TEST_ASSERT_NOT_EQUAL_INT16_MESSAGE(test_value, 0,
            "The $HOME parameter should be expanded when using system()");
    free((void *)test_string);

}

void test_exec_calls()
{
    printf("Running tests at %s : function %s\n",__FILE__,__func__);
    TEST_ASSERT_FALSE_MESSAGE(do_exec(2, "echo", "Testing execv implementation with echo"),
             "The exec() function should have returned false since echo was not specified"
             " with absolute path as a command and PATH expansion is not performed.");
    TEST_ASSERT_FALSE_MESSAGE(do_exec(3, "/usr/bin/test","-f","echo"),
             "The exec() function should have returned false since echo was not specified"
             " with absolute path in argument to the test executable.");
    TEST_ASSERT_TRUE_MESSAGE(do_exec(3, "/usr/bin/test","-f","/bin/echo"),
             "The function should return true since /bin/echo represents the echo command"
             " and test -f verifies this is a valid file");
}

void test_exec_redirect_calls()
{
    printf("Running tests at %s : function %s\n",__FILE__,__func__);
    do_exec_redirect(REDIRECT_FILE, 3, "/bin/sh", "-c", "echo home is $HOME");
    char *test_string = malloc_first_line_of_file(REDIRECT_FILE);
    TEST_ASSERT_NOT_NULL_MESSAGE(test_string,"Nothing written to file at " REDIRECT_FILE );
    if( test_string != NULL ) {
        int test_value = strncmp(test_string, "home is /", 9);
        printf("execv /bin/sh -c echo home is $HOME returned %s\n", test_string);
        // Testing implementation with testfile.txt output 
        TEST_ASSERT_EQUAL_INT16_MESSAGE(test_value, 0,
                "The first 9 chars echoed should be \"home is /\".  The last chars will include "
                "the content of the $HOME variable");
        test_value = strncmp(test_string, "home is $HOME", 9);
        TEST_ASSERT_NOT_EQUAL_INT16_MESSAGE(test_value, 0,
                "The $HOME parameter should be expanded when using /bin/sh with do_exec()");
        free(test_string);
    }

    do_exec_redirect(REDIRECT_FILE, 2, "/bin/echo", "home is $HOME");
    test_string = malloc_first_line_of_file(REDIRECT_FILE);
    TEST_ASSERT_NOT_NULL_MESSAGE(test_string,"Nothing written to file at " REDIRECT_FILE );
    if( test_string != NULL ) {
        printf("execv /bin/echo home is $HOME returned %s\n", test_string);
        // Testing implementation with testfile.txt output 
        TEST_ASSERT_EQUAL_STRING_MESSAGE("home is $HOME", test_string, 
                    "The variable $HOME should not be expanded using execv()");
        free(test_string);
    }
}
