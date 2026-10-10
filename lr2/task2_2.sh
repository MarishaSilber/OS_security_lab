#!/bin/bash
DIR="$(dirname "$(readlink -f "$0")")"
"$DIR/task2_1.sh"
less /tmp/run.log

