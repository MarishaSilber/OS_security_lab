#!/bin/bash

bytes=0
lines=0
count=0

echo "files:"
while IFS= read -r f; do
	echo "$f"
	bytes=$((bytes + $(wc -c < "$f")))
	lines=$((lines + $(wc -l < "$f")))
	count=$((count + 1))
done < <(find "$HOME" -type f -name "*.txt")

echo "count files: $count"
echo "count bytes: $bytes"
echo "count lines: $lines"


