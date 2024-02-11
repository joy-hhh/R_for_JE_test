#!/bin/bash

# 입력 파일의 이름
input_file="$1"

# 출력할 열의 번호
column="$2"

# awk 명령어로 입력 파일에서 해당 열의 최소값과 최대값을 구합니다.
awk -F'\t' -v c="$column" 'NR == 1 { min=$c; max=$c } NR > 1 && $c < min { min=$c } NR > 1 && $c > max { max=$c } END { print "최소값:", min; print "최대값:", max }' "$input_file"

