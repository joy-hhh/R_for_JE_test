#!/bin/bash

# 입력 파일의 이름
input_file="$1"

# 열 개수 세기
colnum=`awk -F'\t' '{print NF; exit}' "$1"`

awk -F"\t" '{ for (i=1; i<='"$colnum"'; i++) { if ($i == "") { count[i]++ }}} END { for (i=1; i<='"$colnum"'; i++) { printf "%d\t", count[i] } printf "\n"}' "$input_file" 
