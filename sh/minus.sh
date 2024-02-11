#!/bin/bash

# 입력 파일의 이름
input_file="$1"

# 출력 파일의 이름
output_file="$2"

# 구분자열
column1="$3"

# 대변 구분자
h="$4"

# 대변값을 마이너스로 변경할 금액 열
column2="$5"


# awk 명령어로 입력 파일에서 해당 조건을 만족하는 행을 찾아서 여섯번째 열의 값을 음수로 바꿉니다.
# 그 결과를 출력 파일에 씁니다.
awk -F'\t' -v c1="$column1" -v h="$h" -v c2="$column2" '$c1 == h { $c2 = -$c2 } 1' OFS='\t' "$input_file" > "$output_file"

