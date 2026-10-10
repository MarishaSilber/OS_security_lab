#!/bin/bash

if (( $# == 0 )); then
    echo "Использование: $0 число [число ...]" >&2
    exit 1
fi

: > even.txt
: > odd.txt

processed=0
skipped=0

for n in "$@"; do
    if ! [[ $n =~ ^-?[0-9]+$ ]]; then
        echo "Предупреждение: '$n' не целое число, пропущено" >&2
        continue
    fi

    abs=$((10#${n#-}))

    if (( abs % 3 == 0 )); then
        skipped=$((skipped + 1))
        continue
    fi

    if (( abs % 2 == 0 )); then
        echo "$n" >> even.txt
    else
        echo "$n" >> odd.txt
    fi
    processed=$((processed + 1))
done

echo "Обработано чисел: $processed (пропущено кратных 3: $skipped)"
