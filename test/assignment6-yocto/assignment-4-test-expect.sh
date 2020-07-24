#!/usr/bin/expect -f
# This file is no longer used. sshpass is used in test to give password as an argument.

set timeout 1000
spawn ./assignment-4-test.sh

expect "?*continue connecting (yes/no)?*"
send -- "yes\r"
send -- "\r"

expect "?*assword:*"
send -- "root\r"
send -- "\r"

expect "?*assword:*"
send -- "root\r"
send -- "\r"

interact
