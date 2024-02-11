#!/bin/bash

# 입력 파일의 이름
input_file="$1"

# 필터링할 열의 번호
column1="$2"

# 필터링할 값의 정규식
regex1="$3"

# Key 값인 전표번호 열의 번호
column2="$4"

# 출력 파일의 이름
output_file="$5"


temp_file="temp.txt"

cut -f"$column2","$column1" "$input_file" > "$temp_file"

cat "$temp_file" | grep "$regex1" > "temp_1.txt"
cut -f"$column2" "temp_1.txt" > "temp_2.txt"
sort -u "temp_2.txt" > "temp_3.txt"

cut -f"$column2","$column1" "$input_file" > "$temp_file"

sort -t$'\t' -k1,1 "temp_3.txt" -o "temp_1.txt"
sort -t$'\t' -k1,1 "$temp_file" -o "temp_2.txt"
join -t$'\t' "temp_1.txt" "temp_2.txt" > "temp_3.txt"
cut -f2 "temp_3.txt" | sort -u > "$output_file"

# 임시 파일을 삭제합니다.
rm "temp_1.txt" "temp_2.txt" "temp_3.txt" "$temp_file"
