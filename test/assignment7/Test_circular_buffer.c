/**
* @file Test_circular_buffer.c
* @brief Unity based test functions for the circular buffer implementation used with Assignments 7 and 8
* @author Dan Walkes
* @date 2020-03-01
* @copyright Copyright (c) 2020
*
* See https://github.com/ThrowTheSwitch/Unity/blob/master/docs/UnityAssertionsReference.md
* for unity assertion references.
*/
#include "unity.h"
#include "../../../aesd-char-driver/aesd-circular-buffer.h"
#include <string.h>

/**
* Write the packet specified in @param writestr to the buffer specified
* by @param buffer
*/
static void write_circular_buffer_packet(struct aesd_circular_buffer *buffer,
                                         const char *writestr)
{
    struct aesd_buffer_entry entry;
    entry.buffptr = writestr;
    entry.size=strlen(writestr);
    aesd_circular_buffer_add_entry(buffer,&entry);
}

/**
* Verify we can find an entry in @param buffer corresponding to a zero referenced byte offset @param entry_offest_byte
* and verify the resulting string at the corresponding offset matches @param expectstring
*/
static void verify_find_entry(struct aesd_circular_buffer *buffer, size_t entry_offset_byte, const char *expectstring)
{
    size_t offset_rtn=0;
    char message[250];
    struct aesd_buffer_entry *rtnentry = aesd_circular_buffer_find_entry_offset_for_fpos(buffer,
                                                entry_offset_byte,
                                                &offset_rtn);
    snprintf(message,sizeof(message),"null pointer unexpected when verifying offset %zu with expect string %s",
                                        entry_offset_byte, expectstring);
    TEST_ASSERT_NOT_NULL_MESSAGE(rtnentry,message);
    snprintf(message,sizeof(message),"entry string does not match expected value at offset %zu",
                                        entry_offset_byte);
    TEST_ASSERT_EQUAL_STRING_MESSAGE(expectstring,&rtnentry->buffptr[offset_rtn],message);
    TEST_ASSERT_EQUAL_UINT32_MESSAGE((uint32_t)rtnentry->size,(uint32_t)strlen(rtnentry->buffptr),
            "size parameter in buffer entry should match total entry length");
}

/**
* Verify we cannot find an entry in @param buffer at offset @param entry_offset_byte (this represents an
* offset past the end of the buffer
*/
static void verify_find_entry_not_found(struct aesd_circular_buffer *buffer, size_t entry_offset_byte)
{
    size_t offset_rtn;
    char message[150];
    struct aesd_buffer_entry *rtnentry = aesd_circular_buffer_find_entry_offset_for_fpos(buffer,
                                                entry_offset_byte,
                                                &offset_rtn);
    snprintf(message,sizeof(message),"Expected null pointer when trying to validate entry offset %zu",entry_offset_byte);
    TEST_ASSERT_NULL_MESSAGE(rtnentry,message);
}

/**
* Tests the circular buffer by writing a set of 10 strings, verifying each request for
* associated offset returns the correct location in the buffer
*/
void test_circular_buffer(void)
{
    struct aesd_circular_buffer buffer;
    aesd_circular_buffer_init(&buffer);
    TEST_MESSAGE("Write strings 1 to 10 to the circular buffer");
    write_circular_buffer_packet(&buffer,"write1\n"); 
    write_circular_buffer_packet(&buffer,"write2\n"); 
    write_circular_buffer_packet(&buffer,"write3\n"); 
    write_circular_buffer_packet(&buffer,"write4\n"); 
    write_circular_buffer_packet(&buffer,"write5\n"); 
    write_circular_buffer_packet(&buffer,"write6\n"); 
    write_circular_buffer_packet(&buffer,"write7\n"); 
    write_circular_buffer_packet(&buffer,"write8\n"); 
    write_circular_buffer_packet(&buffer,"write9\n"); 
    write_circular_buffer_packet(&buffer,"write10\n"); 
    TEST_MESSAGE("Verify strings 1 through 10 exist in the circular buffer");
    verify_find_entry(&buffer,0,"write1\n");
    verify_find_entry(&buffer,7,"write2\n");
    verify_find_entry(&buffer,14,"write3\n");
    verify_find_entry(&buffer,21,"write4\n");
    verify_find_entry(&buffer,28,"write5\n");
    verify_find_entry(&buffer,35,"write6\n");
    verify_find_entry(&buffer,42,"write7\n");
    verify_find_entry(&buffer,49,"write8\n");
    verify_find_entry(&buffer,56,"write9\n");
    verify_find_entry(&buffer,63,"write10\n");
    TEST_MESSAGE("Verify a request for the last byte in the circular buffer succeeds");
    verify_find_entry(&buffer,70,"\n");
    TEST_MESSAGE("Verify a request for one offset past the last byte in the circular buffer returns not found");
    verify_find_entry_not_found(&buffer,71);
    TEST_MESSAGE("Write one more packet to the circular buffer, causing the first entry to be removed");
    write_circular_buffer_packet(&buffer,"write11\n"); 
    TEST_MESSAGE("Verify the first entry is removed, and all other remaining entries are found at the correct offsets");
    verify_find_entry(&buffer,0,"write2\n");
    verify_find_entry(&buffer,7,"write3\n");
    verify_find_entry(&buffer,14,"write4\n");
    verify_find_entry(&buffer,21,"write5\n");
    verify_find_entry(&buffer,28,"write6\n");
    verify_find_entry(&buffer,35,"write7\n");
    verify_find_entry(&buffer,42,"write8\n");
    verify_find_entry(&buffer,49,"write9\n");
    verify_find_entry(&buffer,56,"write10\n");
    verify_find_entry(&buffer,64,"write11\n");
    verify_find_entry(&buffer,71,"\n");
    verify_find_entry_not_found(&buffer,72);
}
