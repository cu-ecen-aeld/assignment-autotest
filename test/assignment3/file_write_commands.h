/*
* Leverage code:
* https://raw.githubusercontent.com/cu-ecen-5013/assignment-autotest/issue61/test/assignment1/username-from-conf-file.h
*
*/

#include "unity.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include "examples/autotest-validate/autotest-validate.h"


/**
* Verify we can automated test code in the "examples" directory within your project
*/

/**
 * @return the content of the file, and validate using string assertions
 */

static inline char * malloc_first_line_of_file(const char *filename)
{
    size_t len = 0;
    char *buffer = NULL;
    FILE *fp = fopen("testfile.txt","r");
    ssize_t bytes_read = -1;
    if ( fp != NULL ) {
        /**
         * See https://www.gnu.org/software/libc/manual/html_mono/libc.html#index-getdelim-994
         */
        bytes_read = getline(&buffer, &len, fp);
        if ( bytes_read < 1 ) {
            printf("Could not read from conf/username.txt\n");
        } else {
            // remove delimeter
            if ( buffer[bytes_read-1] == '\r' || buffer[bytes_read-1] == '\n' ) {
                buffer[bytes_read-1] = 0;
                printf("Remove trailing newline\n");
            }
            printf("Read %s from testfile.txt\n",buffer);
        }
    } else {
        printf("Could not open testfile.txt for reading\n");
    }
    return buffer;
}
