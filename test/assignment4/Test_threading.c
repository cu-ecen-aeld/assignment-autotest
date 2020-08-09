#define _GNU_SOURCE // use the gnu extension so we have pthread_tryjoin_mp available
#include <pthread.h>
#include "unity.h"
#include <stdbool.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>
#include "../../../examples/threading/threading.h"

/**
 * Wait to ensure @param sleep_before_check has expired, then verify @parma thread is joinable and
 * has 0 exit status
 */
static void validate_thread_joinable_after_mutex_unlock(pthread_t *thread,unsigned int sleep_before_check_ms)
{
    int tryjoin_rtn = 0;
    void * thread_rtn = NULL;
    if (sleep_before_check_ms > 0 ) {
        /**
         * Sleep for 20 * the amount of sleep before lock to
         * to check for thread joinable.  There's no guarantee this will be enough so don't fail
         * if it's not, but print a warning about what likely is wrong if the pthread_join step fails.
         */
        TEST_ASSERT_EQUAL_INT_MESSAGE(0,usleep(sleep_before_check_ms*1000),
                    "usleep was interrupted");
    }

    tryjoin_rtn = pthread_tryjoin_np(*thread,&thread_rtn);
    if( tryjoin_rtn != 0 ) {
        printf("WARNING!!!! - Thread is not joinable after a delay of %d ms.  If the test hangs at the next step, assume you haven't\n"
                "correctly implemented threading logic and your thread is not actually exiting after locking the mutex.\n",
                sleep_before_check_ms);
        TEST_ASSERT_EQUAL_INT_MESSAGE(0,pthread_join(*thread,&thread_rtn),
                "The thread should be able to be joined after mutex is unlocked");
    }

    TEST_ASSERT_NOT_NULL_MESSAGE(thread_rtn,"The thread function should not have returned a null pointer");
    if( thread_rtn ) {
        struct thread_data* thread_func_data = (struct thread_data *) thread_rtn;
        TEST_ASSERT_TRUE_MESSAGE(thread_func_data->thread_complete_success,
                "The thread_complete_success value should be set to true in the thread return structure");
        free(thread_rtn);
    }
}


/**
 * Validate the thread @param thread correctly handles mutex unlock assuming it's sleeping
 * @param sleep_before_lock_ms before attempting to obtain a lock and sleeping
 * @param sleep_after_lock_ms after the lock is obtained.
 * Ensure the thread has exited (and is joinable) only after the mutex is unlocked and after
 * @param sleep_after_unlock_ms
 */
static void validate_thread_waits_for_mutex(pthread_t *thread, pthread_mutex_t *mutex,
                                            unsigned int sleep_before_lock_ms,
                                            unsigned int sleep_after_lock_ms)
{
    void * thread_rtn;
    /**
     * Sleep for 20 * the amount of sleep before lock to
     * make sure the thread is actually waiting on the mutex
     */
    TEST_ASSERT_EQUAL_INT_MESSAGE(0,usleep(sleep_before_lock_ms*20*1000),
                "usleep was interrupted");

    TEST_ASSERT_EQUAL_INT_MESSAGE(EBUSY,pthread_tryjoin_np(*thread,&thread_rtn),
                "Attempts to join the thread should fail with EBUSY (since the mutex is still locked)");
    /**
     * Unlock the mutex, then sleep another 20 ms.
     * This should give our thread the opportunity to wait 1ms and release the mutex
     */
    TEST_ASSERT_EQUAL_INT_MESSAGE(0,pthread_mutex_unlock(mutex),
                "pthread_mutex_unlock should succed on locked mutex");
   
    /**
     * wait 20* the amount of sleep after lock to ensure the thread had a chance to complete
     */ 
    validate_thread_joinable_after_mutex_unlock(thread,sleep_after_lock_ms*20);

}
/**
 * This test case verifies the start_thread_obtaining_mutex function can be called with locked mutexes
 * and joinable is not set until the mutex is released and a wait of wait_to_release_ms*number of seconds elapses.
 *
*/
void test_threading_single_locked_mutex()
{
    pthread_t thread;
    pthread_mutex_t mutex;
    bool thread_started = false;
    TEST_ASSERT_EQUAL_INT_MESSAGE(0,pthread_mutex_init(&mutex, NULL),
                    "pthread_mutex_init should succeed");
    TEST_ASSERT_EQUAL_INT_MESSAGE(0,pthread_mutex_lock(&mutex),
                    "pthread_mutex_lock should succeed");
    printf("Start a thread obtaining a locked mutex, sleeping 1 millisecond before locking and waiting to return\n");
    printf("until 1 millisecond after locking.\n");
    thread_started = start_thread_obtaining_mutex(&thread, &mutex, 1, 1);
    TEST_ASSERT_TRUE_MESSAGE(thread_started,
                "start_thread_obtaining_mutex should start a new thread with locked mutex");
    if (thread_started) {
        validate_thread_waits_for_mutex(&thread,&mutex,1,1);
    }
        
    TEST_ASSERT_EQUAL_INT_MESSAGE(0, pthread_mutex_destroy(&mutex),
            "The mutex should be able to be destroyed succesfully at the conclusion of the test");
}

/**
 * This test verifies the threads handle unlocked mutex cases appropriately
 * and just waits for sleep_before_lock and sleep_after_lock conditions, then exits
 */
void test_threading_single_unlocked_mutex()
{
    pthread_t thread;
    pthread_mutex_t mutex;
    TEST_ASSERT_EQUAL_INT_MESSAGE(0,pthread_mutex_init(&mutex, NULL),
                    "pthread_mutex_init should succeed");
    printf("Start a thread which waits 250ms before attempting to obtain a mutex, then waits\n"
           "250ms to release.  Since we aren't locking the mutex in this case, the thread\n"
           "should not block on mutex_lock()\n");
    bool thread_started = start_thread_obtaining_mutex(&thread, &mutex, 250,
                                                                    250);
    TEST_ASSERT_TRUE_MESSAGE(thread_started,
                "start_thread_obtaining_mutex should start a new thread with locked mutex");
 
    if( thread_started ) { 
        validate_thread_joinable_after_mutex_unlock(&thread,700);
    }

}

/**
 * Move the logic above related to starting a thread in a single function, so we don't need to
 * continue to repeat it in following tests
 * @param thread the thread to start
 * @param mutex the mutex to associate with the thread.  Initialize and lock it
 * @param sleep_before_lock the amount of time to sleep before locking the mutex
 * @param sleep_after_lock the amount of time to sleep after locking the mutex
 */
bool validate_thread_setup(pthread_t *thread, pthread_mutex_t *mutex, unsigned int sleep_before_lock,
                            unsigned int sleep_after_lock)
{
    TEST_ASSERT_EQUAL_INT_MESSAGE(0,pthread_mutex_init(mutex, NULL),
                    "pthread_mutex_init should succeed");
    TEST_ASSERT_EQUAL_INT_MESSAGE(0,pthread_mutex_lock(mutex),
                    "pthread_mutex_lock should succeed");
    bool thread_started = start_thread_obtaining_mutex(thread, mutex, sleep_before_lock,
                                                                    sleep_after_lock);
    TEST_ASSERT_TRUE_MESSAGE(thread_started,
                "start_thread_obtaining_mutex should start a new thread with locked mutex");
    return thread_started;
}

/**
 * This test verifies multiple threads can be started at once and each one waits for the appropriate
 * mutex before completing.  If this test fails it probably means you aren't correctly handling
 * mutiple threads with dynamic allocation, or aren't correctly allocating the right mutex to the
 * appropriate threads.
 */
void test_threading_two_threads_two_mutexes()
{
    pthread_t thread1;
    pthread_mutex_t mutex1;
    bool thread1_started = false;
    pthread_t thread2;
    pthread_mutex_t mutex2;
    bool thread2_started = false;

    printf("Setting up thread 1\n");
    printf("Start a thread obtaining a locked mutex, sleeping 1 millisecond before locking and waiting to return\n");
    printf("until 1 millisecond after locking.\n");
    
    thread1_started = validate_thread_setup(&thread1,&mutex1,1,1);
 
    printf("Setting up thread 2\n");
    printf("Start a thread obtaining a locked mutex, sleeping 1 millisecond before locking and waiting to return\n");
    printf("until 1 millisecond after locking.\n");
    
    thread2_started = validate_thread_setup(&thread2,&mutex2,1,1);

    if( thread1_started && thread2_started ) {
        printf("Verifying thread 1\n");
        validate_thread_waits_for_mutex(&thread1,&mutex1,1,1);
        printf("Verifying thread 2\n");
        validate_thread_waits_for_mutex(&thread2,&mutex2,1,1);
    }
    TEST_ASSERT_EQUAL_INT_MESSAGE(0, pthread_mutex_destroy(&mutex1),
            "The mutex should be able to be destroyed succesfully at the conclusion of the test");
    TEST_ASSERT_EQUAL_INT_MESSAGE(0, pthread_mutex_destroy(&mutex2),
            "The mutex should be able to be destroyed succesfully at the conclusion of the test");
}

/**
 * This test is similar to the two_threads_two_mutex case but 
 * each thread shares the same mutex.
 */
void test_threading_two_threads_one_mutex()
{
    pthread_t thread1;
    pthread_mutex_t mutex1;
    bool thread1_started = false;
    pthread_t thread2;
    bool thread2_started = false;

    printf("Setting up thread 1\n");
    printf("Start a thread obtaining a locked mutex, sleeping 1 millisecond before locking and waiting to return\n");
    printf("until 1 millisecond after locking.\n");
    
    thread1_started = validate_thread_setup(&thread1,&mutex1,1,1);
 
    printf("Setting up thread 2\n");
    printf("Start a thread obtaining a locked mutex, sleeping 1 millisecond before locking and waiting to return\n");
    printf("until 1 millisecond after locking, using the same mutex as thread 1\n");
    
    thread2_started = validate_thread_setup(&thread2,&mutex1,1,1);

    if( thread1_started && thread2_started ) {
        printf("Verifying thread 1\n");
        validate_thread_waits_for_mutex(&thread1,&mutex1,1,1);
        printf("Verifying thread 2 (which uses the same mutex as thread 1 and should not require unlock)\n");
        validate_thread_joinable_after_mutex_unlock(&thread2,0);
    }
}
