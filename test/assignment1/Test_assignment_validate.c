#include "unity.h"
#include <stdbool.h>
#include "examples/autotest-validate/autotest-validate.h"


/**
* Verify we can automated test code in the "examples" directory within your project
*/
void test_assignment_validate()
{
    TEST_ASSERT_TRUE_MESSAGE(this_function_returns_true(),"The function should return true");
    TEST_ASSERT_FALSE_MESSAGE(this_function_returns_false(),"The function should have returned false");
}
