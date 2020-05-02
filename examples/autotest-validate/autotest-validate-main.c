#include <stdio.h>
#include "autotest-validate.h"

int main(int argc, char**argv)
{
    printf("this_function_returns_true returned %s\n",
                this_function_returns_true() ? "true" : "false");
    printf("this_function_returns_false returned %s\n",
                this_function_returns_false() ? "true" : "false");
}
