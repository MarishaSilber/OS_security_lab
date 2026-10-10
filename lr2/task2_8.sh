#!/bin/bash

usage() {
    cat <<USAGE
Использование: $0 [-h] [-v] [-o файл] ОПЕРАЦИЯ число число [число ...]

Опции:
  -h        показать эту справку
  -v        подробный вывод (показывать каждый шаг)
  -o файл   записать результат в файл

Операция (ровно одна):
  -a  сложение            -s  вычитание
  -m  умножение           -d  деление
  -p  возведение в степень

Вычисление идёт слева направо: a op b op c.
Отрицательные числа передавайте после --, например:
  $0 -a -- -5 3
USAGE
}

verbose=0
outfile=""
op=""

while getopts ":hvo:asmpd" opt; do
    case $opt in
        h) usage; exit 0 ;;
        v) verbose=1 ;;
        o) outfile=$OPTARG ;;
        a|s|m|p|d)
            if [[ -n $op ]]; then
                echo "Ошибка: можно указать только одну операцию" >&2
                exit 1
            fi
            op=$opt ;;
        :)  echo "Ошибка: опции -$OPTARG нужен аргумент" >&2; exit 1 ;;
        \?) echo "Ошибка: неизвестная опция -$OPTARG" >&2; usage >&2; exit 1 ;;
    esac
done
shift $((OPTIND - 1))

if [[ -z $op ]]; then
    echo "Ошибка: не указана операция (-a, -s, -m, -d или -p)" >&2
    usage >&2
    exit 1
fi

if (( $# < 2 )); then
    echo "Ошибка: нужно минимум два числа" >&2
    exit 1
fi

for x in "$@"; do
    if ! [[ $x =~ ^-?[0-9]+([.][0-9]+)?$ ]]; then
        echo "Ошибка: '$x' - не число" >&2
        exit 1
    fi
done

case $op in
    a) sym="+" ;;
    s) sym="-" ;;
    m) sym="*" ;;
    d) sym="/" ;;
    p) sym="^" ;;
esac

calc() {
    awk -v x="$1" -v y="$2" -v op="$3" 'BEGIN {
        if (op == "+") r = x + y
        else if (op == "-") r = x - y
        else if (op == "*") r = x * y
        else if (op == "^") r = x ^ y
        else if (op == "/") { if (y == 0) exit 2; r = x / y }
        printf "%.10g\n", r
    }'
}

result=$1
shift
output=""

for next in "$@"; do
    new=$(calc "$result" "$next" "$sym") || {
        echo "Ошибка: деление на ноль" >&2
        exit 1
    }
    if (( verbose )); then
        output+="$result $sym $next = $new"$'\n'
    fi
    result=$new
done
output+="Результат: $result"

if [[ -n $outfile ]]; then
    printf '%s\n' "$output" > "$outfile"
    echo "Результат записан в файл $outfile"
else
    printf '%s\n' "$output"
fi
