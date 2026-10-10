#!/bin/bash
LOG="/tmp/run.log"
touch "$LOG"
previous=$(wc -l < "$LOG")
date >> "$LOG"
echo "Hello, World!"
echo "$previous" >&2

