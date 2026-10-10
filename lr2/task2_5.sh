#!/bin/bash
dir="${1:-.}"

if [[ ! -d $dir ]]; then
    echo "Ошибка: '$dir' - не каталог" >&2
    exit 1
fi

find "$dir" -type f -print0 | xargs -0 -r sha256sum | awk '
{
    hash = substr($0, 1, 64)
    name = substr($0, 67)
    n[hash]++
    files[hash, n[hash]] = name
}
END {
    for (h in n)
        if (n[h] > 1)
            for (i = 1; i <= n[h]; i++)
                print n[h] - 1, files[h, i]
}'
