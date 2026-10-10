#!/bin/bash

usage() {
    cat <<USAGE
Использование: $0 [-f txt|csv] [-g] [-h] файл.csv

  -f txt|csv  формат отчёта (по умолчанию txt):
              txt -> sales_report.txt, csv -> sales_report.csv
  -g          сгенерировать SQL (PostgreSQL) для импорта sales_report.csv
              в таблицу sales_report -> файл sales_import.sql
  -h          справка
USAGE
}

format="txt"
gen_sql=0

while getopts ":f:gh" opt; do
    case $opt in
        f) format=$OPTARG ;;
        g) gen_sql=1 ;;
        h) usage; exit 0 ;;
        :)  echo "Ошибка: опции -$OPTARG нужен аргумент" >&2; exit 1 ;;
        \?) echo "Ошибка: неизвестная опция -$OPTARG" >&2; usage >&2; exit 1 ;;
    esac
done
shift $((OPTIND - 1))

if [[ $format != txt && $format != csv ]]; then
    echo "Ошибка: формат должен быть txt или csv" >&2
    exit 1
fi

input=$1
if [[ -z $input ]]; then
    echo "Ошибка: не указан CSV-файл" >&2
    usage >&2
    exit 1
fi
if [[ ! -r $input ]]; then
    echo "Ошибка: файл '$input' не найден или недоступен" >&2
    exit 1
fi

stats=$(awk -F, '
    { sub(/\r$/, "") }
    NR == 1 { next }
    NF < 5  { next }
    {
        amount = $4 * $5
        count++
        total += amount
        if (count == 1 || amount > max) { max = amount; prod = $3 }
    }
    END {
        if (count == 0) exit 3
        printf "%d\t%.2f\t%.2f\t%.2f\t%s\n", count, total, total / count, max, prod
    }' "$input") || {
    echo "Ошибка: в файле нет данных о продажах" >&2
    exit 1
}

IFS=$'\t' read -r count total avg max prod <<< "$stats"

report_txt() {
    echo "Отчёт по продажам (файл: $input)"
    echo "Количество продаж: $count"
    echo "1) Общая сумма продаж: $total"
    echo "2) Средняя стоимость продажи: $avg"
    echo "3) Самая дорогая продажа: $max (товар: $prod)"
}

report_csv() {
    echo "total_sales,average_sale,max_sale,max_sale_product"
    echo "$total,$avg,$max,\"${prod//\"/\"\"}\""
}

report_sql() {
    local path
    path=$(readlink -f sales_report.csv)
    cat <<SQL
CREATE TABLE IF NOT EXISTS sales_report (
    total_sales      NUMERIC(14,2) NOT NULL,
    average_sale     NUMERIC(14,2) NOT NULL,
    max_sale         NUMERIC(14,2) NOT NULL,
    max_sale_product TEXT          NOT NULL
);

COPY sales_report (total_sales, average_sale, max_sale, max_sale_product)
FROM '$path'
WITH (FORMAT csv, HEADER true);
SQL
}

if [[ $format == csv ]]; then
    report_csv | tee sales_report.csv
else
    report_txt | tee sales_report.txt
fi

if (( gen_sql )); then
    [[ $format == csv ]] || report_csv > sales_report.csv
    echo
    report_sql | tee sales_import.sql
fi
