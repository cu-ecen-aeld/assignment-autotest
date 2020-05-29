#include <stdio.h>
#include <stdlib.h>

/**
 * @return the name of the user from the conf file, or
 * an empty string if not found.  Must be freed by the caller
 */
static inline char *malloc_username_from_conf_file()
{
    size_t len = 0;
    char *buffer = malloc(1);
    FILE *fp = fopen("conf/username.txt","r");
    ssize_t bytes_read = -1;
    buffer[0] = 0;
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
            printf("Read %s from conf/username.txt\n",buffer);
        }
    } else {
        printf("Could not open conf/username.txt for reading\n");
    }
    return buffer;
}
