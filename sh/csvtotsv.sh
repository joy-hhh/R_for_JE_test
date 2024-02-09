#!/bin/bash

# 입력 파일의 이름을 변수로 저장합니다.
input_file="$1"

# 출력 파일의 이름을 변수로 저장합니다.
output_file="$2"

# tr 명령어로 입력 파일에서 쉼표를 탭으로 바꿉니다.
# 그 결과를 출력 파일에 씁니다.
tr ',' '\\t' <"$input_file" >"$output_file"

