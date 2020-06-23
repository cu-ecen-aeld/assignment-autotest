#include "unity.h"
#include <stdbool.h>
#include <stdlib.h>
#include "../../../../examples/threading/threading.h"

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
void test_threading()
{
    /**
     * TODO: Replace the line below with your code here as described above to verify your do_system, do_exec()
     * and do_exec_redirect() functions are setup properly.
     */

    openlog(NULL, LOG_PERROR | LOG_CONS, LOG_USER);

    void * test_my_Ass;
    pthread_t * thread1, *thread2;
    thread1 = malloc(1 * sizeof(pthread_t));
    pthread_mutex_t *mutex_1, *mutex_2;
    mutex_1 = malloc(1 * sizeof(pthread_mutex_t));
    pthread_mutex_init(mutex_1, NULL);
    pthread_mutex_lock(mutex_1);
    syslog(LOG_DEBUG, start_thread_obtaining_mutex(thread1, mutex_1, 1, 1) ? "Value: true\n" : "Value: false\n");
    syslog(LOG_DEBUG, "Thread ID main 1: %ld, mutex 1: %d\n", *thread1, *mutex_1->__size);
    pthread_mutex_destroy(mutex_1); 
    int ret = pthread_join(*thread1, &test_my_Ass);
    syslog(LOG_DEBUG, "ret in first case: %d, test_varaible%d\n", ret, (int )test_my_Ass);

    TEST_ASSERT_EQUAL_INT16_MESSAGE(ret, 0, "test waiting for thread to complete"); 

    free(mutex_1);
    free(thread1);

    thread1 = malloc(1 * sizeof(pthread_t));
    thread2 = malloc(1 * sizeof(pthread_t));
    mutex_1 = malloc(1 * sizeof(pthread_mutex_t));
    mutex_2 = malloc(1 * sizeof(pthread_mutex_t));
    pthread_mutex_init(mutex_1, NULL);
    pthread_mutex_init(mutex_2, NULL);
    pthread_mutex_unlock(mutex_2);
    pthread_mutex_lock(mutex_1);
    syslog(LOG_DEBUG, start_thread_obtaining_mutex(thread2, mutex_2, 1, 1) ? "Value: true\n" : "Value: false\n");
    syslog(LOG_DEBUG, "Thread ID main 2: %ld, mutex_2: %d", *thread2, *mutex_2->__size);
    syslog(LOG_DEBUG, start_thread_obtaining_mutex(thread1, mutex_1, 1, 1) ? "Value: true\n" : "Value: false\n");
    syslog(LOG_DEBUG, "Thread ID main 1: %ld, mutex 1: %d\n", *thread1, *mutex_1->__size);
    pthread_mutex_destroy(mutex_1); 
    pthread_mutex_destroy(mutex_2);

    ret = pthread_join(*thread2, &test_my_Ass);
    syslog(LOG_DEBUG, "ret in second case: %d, test_varaible%d\n", ret, (int )test_my_Ass);
    TEST_ASSERT_EQUAL_INT16_MESSAGE(ret, 0, "test waiting for thread 2 to complete");

    ret = pthread_join(*thread1, &test_my_Ass);
    syslog(LOG_DEBUG, "ret in first case: %d, test_variable: %d\n", ret, (int)test_my_Ass);
    TEST_ASSERT_NOT_EQUAL_INT16_MESSAGE(&test_my_Ass, 0, "test waiting for thread 1 to complete"); 

    free(mutex_1);
    free(mutex_2);
    free(thread1);
    free(thread2);
}

