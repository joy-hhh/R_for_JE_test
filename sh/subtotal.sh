#!/bin/bash

filename="$1"
group="$2"
amount="$3"
output_file="$4"

# 첫번째 열의 값과 여섯번째 열의 숫자를 공백으로 구분하여 잘라냅니다.
cut -f $group,$amount $filename > temp.txt

# 잘라낸 파일을 첫번째 열의 값으로 정렬합니다.
sort -k1,1 temp.txt > sorted.txt

# 정렬된 파일을 읽으면서 첫번째 열의 값이 바뀔 때마다 그룹별로 합산합니다.
# 그 결과를 출력 파일에 씁니다.
awk 'BEGIN {FS=OFS="\t"} {if ($1 == prev) {sum += $2} else {if (NR > 1) {print prev, sum}; prev = $1; sum = $2}} END {print prev, sum}' sorted.txt > $output_file

# 임시 파일을 삭제합니다.
rm temp.txt sorted.txt
