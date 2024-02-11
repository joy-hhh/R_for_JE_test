#!/bin/bash

# 입력 파일의 이름
input_file="$1"

# 계정과목열의 번호
column1="$2"

# 필터링할 값
regex1="$3"
regex2="$4"

# 전표번호 열(Key)의 번호
column2="$5"

# 출력 파일의 이름
output_file="$6"


temp_file="temp.txt"
cat "$input_file" | grep "$regex1" > "temp_1.txt"
cat "$input_file" | grep "$regex2" > "temp_2.txt"
cut -f"$column2" "temp_1.txt" | sort -u > "temp_3.txt"
cut -f"$column2" "temp_2.txt" | sort -u > "temp_4.txt"

cut -f"$column2"- "$input_file" > "$temp_file"

sort -t$'\t' -k1,1 "temp_3.txt" -o "temp_1.txt"
sort -t$'\t' -k1,1 "temp_4.txt" -o "temp_2.txt"
sort -t$'\t' -k1,1 -o "$temp_file" "$temp_file"

join -t$'\t' "temp_1.txt" "temp_2.txt" > "temp_3.txt"
join -t$'\t' "$temp_file" "temp_3.txt" > "$output_file"


# 임시 파일을 삭제합니다.
rm "temp_1.txt" "temp_2.txt" "temp_3.txt" "temp_4.txt" "$temp_file"
