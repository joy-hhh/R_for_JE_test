#!/bin/bash

# 입력 파일의 이름을 변수로 저장합니다.
input_file="$1"

# 출력 파일의 이름을 변수로 저장합니다.
output_file="$2"

# 필터링할 열의 번호를 변수로 저장합니다.
column1="$3"

# 필터링할 값의 정규식을 변수로 저장합니다.
regex1="$4"

# 중복을 제거할 열의 번호를 변수로 저장합니다.
column2="$5"

# 임시 파일의 이름을 변수로 저장합니다.
temp_file="temp.txt"

cat "$input_file" | grep "$regex1" > "temp_1.txt"
cut -f"$5" "temp_1.txt" > "temp_2.txt"
sort -u "temp_2.txt" > "temp_3.txt"

cut -f"$5","$3" "$input_file" > "$temp_file"

sort -t$'\t' -k1,1 "temp_3.txt" -o "temp_1.txt"
sort -t$'\t' -k1,1 "$temp_file" -o "temp_2.txt"
join -t$'\t' "temp_1.txt" "temp_2.txt" > "temp_3.txt"
cut -f2 "temp_3.txt" | sort -u > "$output_file"

# 임시 파일을 삭제합니다.
rm "temp_1.txt" "temp_2.txt" "temp_3.txt" "$temp_file"
