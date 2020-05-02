#include "unity.h"
#include <stdbool.h>

void test_hello()
{
    TEST_MESSAGE("Hello!  Your unity setup is working!");
    TEST_ASSERT_TRUE_MESSAGE(true,"This assertion passed!");
//    Remove the comment on the line below to see what happens with failed assertions
//    TEST_ASSERT_TRUE_MESSAGE(false,"This assertion failed (as expected)");
}
