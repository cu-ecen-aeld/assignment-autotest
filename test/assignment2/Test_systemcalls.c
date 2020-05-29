#include "unity.h"
#include <stdbool.h>
#include <stdlib.h>
#include "../../../examples/systemcalls/systemcalls.h"
#include "file_write_commands.h"

/**
* This function should:
*   1) Call the do_system() function in systemcalls.c to perform the system() operation.
*   2) Obtain the value returned from return_string_validation() in file_write_commands.h within
*       the assignment autotest submodule at assignment-autotest/test/assignment2/
*   3) Use unity assertion TEST_ASSERT_EQUAL_STRING_MESSAGE the two strings are equal.  See
*       the [unity assertion reference](https://github.com/ThrowTheSwitch/Unity/blob/master/docs/UnityAssertionsReference.md)
*   4) Test with strncmp fo string which return the full path for $HOME,
*       and compare the value using TEST_ASSERT_EQUAL_INT16_MESSAGE.
*   5) Call the do_exec() function in systemcalls.c to perform fork(), execv() and wait() instead of using the system() command.
*   6) Test for a true and false message on the above commands using TEST_ASSERT_FALSE_MESSAGE(TRUE_MESSAGE).
*   7) Call the do_exec_redirect() function in systemcalls.c to perform the same operation as do_exec(),
*       but redirect ouptut to standard out.
*   8) Obtain the value returned from return_string_validation() in file_write_commands.h within
*       the assignment autotest submodule at assignment-autotest/test/assignment2/
*   9) Use unity assertion TEST_ASSERT_EQUAL_STRING_MESSAGE the two strings are equal.
*
**/
void test_systemcalls()
{
    /**
     * TODO: Replace the line below with your code here as described above to verify your do_system, do_exec()
     * and do_exec_redirect() functions are setup properly.
     */
    do_system(4, "echo","this is a test",">","testfile.txt");
    const char *test_string = return_string_validation();
    // Testing implementation with testfile.txt output 
    TEST_ASSERT_EQUAL_STRING_MESSAGE("this is a test", test_string, "This is a test");
    free((void *)test_string);

    do_system(4, "echo","home is $HOME",">","testfile.txt");
    test_string = return_string_validation();
    int test_value = strncmp(test_string, "home is /home/", 14);
    // Testing implementation with testfile.txt output 
    TEST_ASSERT_EQUAL_INT16_MESSAGE(test_value, 0, "test home is $HOME echo");
    free((void *)test_string);

    TEST_ASSERT_FALSE_MESSAGE(do_exec(2, "echo", "Testing execv implementation with echo"),"The do_Exec(2) function should have returned false");
    // do_exec(2, "/bin/echo", "Testing execv implementation with /bin/echo");
    TEST_ASSERT_FALSE_MESSAGE(do_exec(3, "/usr/bin/test","-f","echo"),"The function should have returned false");
    TEST_ASSERT_TRUE_MESSAGE(do_exec(3, "/usr/bin/test","-f","/bin/echo"),"The function should return true");

    do_exec_redirect("testfile.txt", 3, "/bin/sh", "-c", "echo home is $HOME");
    const char *test_string_2 = return_string_validation();
    test_value = strncmp(test_string_2, "home is /home/", 14);
    // Testing implementation with testfile.txt output 
    TEST_ASSERT_EQUAL_INT16_MESSAGE(test_value, 0, "test home is $HOME full path");
    free((void *)test_string_2);

    do_exec_redirect("testfile.txt", 2, "/bin/echo", "home is $HOME");
    test_string_2 = return_string_validation();
    // Testing implementation with testfile.txt output 
    TEST_ASSERT_EQUAL_STRING_MESSAGE("home is $HOME", test_string_2, "test home is $HOME");
    free((void *)test_string_2);

}