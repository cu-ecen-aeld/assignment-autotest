#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

/**
 * @return the name of the user from the conf file, or
 * an empty string if not found.  Must be freed by the caller
 */
static inline char *malloc_username_from_conf_file()
{
    size_t len = 0;
    // Note: this buffer will be reallocated in getline() as necessary
    char *buffer = malloc(len + 1);
    buffer[0] = '\0';

    FILE *fp = fopen("conf/username.txt","r");
    if ( fp != NULL ) {
        /**
         * See https://man7.org/linux/man-pages/man3/getline.3.html
         */
        ssize_t bytes_read = getline(&buffer, &len, fp);

        // remove whitespace from the end
        while ( bytes_read > 0 && !isgraph(buffer[bytes_read-1]) ) {
            buffer[bytes_read-1] = '\0';
            bytes_read--;
        }

        // remove whitespace from the front
        char *start = &buffer[0];
        while ( bytes_read > 0 && !isgraph(start[0]) && (++start)[0] != '\0' ) {}
        if ( start != buffer ) {
            memmove(buffer, start, strlen(start)+1);
        }

        if ( bytes_read < 1 ) {
            fprintf(stderr, "Could not find username in conf/username.txt\n");
        } else {
            printf("Read %s from conf/username.txt\n", buffer);
        }
    } else {
        fprintf(stderr, "Could not open conf/username.txt for reading\n");
    }
    return buffer;
}
