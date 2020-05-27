#include "unity.h"
#include <stdbool.h>
#include <stdlib.h>
#include "../../../examples/systemcalls/systemcalls.h"
#include "file_write_commands.h"

/**
* This function should:
*   1) Call the my_username() function in Test_assignment_validate.c to get your hard coded username.
*   2) Obtain the value returned from function malloc_username_from_conf_file() in username-from-conf-file.h within
*       the assignment autotest submodule at assignment-autotest/test/assignment1/
*   3) Use unity assertion TEST_ASSERT_EQUAL_STRING_MESSAGE the two strings are equal.  See
*       the [unity assertion reference](https://github.com/ThrowTheSwitch/Unity/blob/master/docs/UnityAssertionsReference.md)
*/
void test_systemcalls()
{
    /**
     * TODO: Replace the line below with your code here as described above to verify your /conf/username.txt 
     * config file and my_username() functions are setup properly
     */
    do_system(4, "echo","this is a test",">","testfile.txt");
    const char *test_string = return_string_validation();
    // Testing implementation with hardcoded name 
    TEST_ASSERT_EQUAL_STRING_MESSAGE("this is a test", test_string, "The username in my_username() should match the username in the configuration file");
    free((void *)test_string);
    do_system(4, "echo","home is $HOME",">","testfile.txt");
    
    TEST_ASSERT_FALSE_MESSAGE(do_exec(2, "echo", "Testing execv implementation with echo"),"The do_Exec(2) function should have returned false");
    // do_exec(2, "/bin/echo", "Testing execv implementation with /bin/echo");
    TEST_ASSERT_FALSE_MESSAGE(do_exec(3, "/usr/bin/test","-f","echo"),"The function should have returned false");
    TEST_ASSERT_TRUE_MESSAGE(do_exec(3, "/usr/bin/test","-f","/bin/echo"),"The function should return true");

    do_exec_redirect("testfile.txt", 4, "/bin/sh", "-c", "echo home is $HOME");
    const char *test_string_2 = return_string_validation();
    // Testing implementation with hardcoded name 
    TEST_ASSERT_EQUAL_STRING_MESSAGE("home is /home/akshita", test_string_2, "test home is $HOME");
    free((void *)test_string_2);

    do_exec_redirect("testfile.txt", 2, "/bin/echo", "home is $HOME");
    test_string_2 = return_string_validation();
    // Testing implementation with hardcoded name 
    TEST_ASSERT_EQUAL_STRING_MESSAGE("home is $HOME", test_string_2, "test home is $HOME");
    free((void *)test_string_2);

}