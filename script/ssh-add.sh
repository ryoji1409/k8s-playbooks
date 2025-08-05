#!/bin/sh
# This script should be executed inside the container using the 'source' command.

set -e

eval "$(ssh-agent)"

expect -c '
    spawn ssh-add $env(SSH_KEY_PATH)
    expect {
        "Enter passphrase for*" {
            send "$env(SSH_PW)\r"
            exp_continue
        }
        eof
    }
'
