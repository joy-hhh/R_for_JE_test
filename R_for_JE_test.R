library(readxl)
library(tidyverse)


# Obtain data from read file
# 
# 
je <- read_csv('je.csv', locale=locale('ko',encoding='euc-kr')) 
View(je)


# A01 test : Data Integrity
# 
# 
colnames(je)
str(je)  
table(is.na(je))  
sapply(je, function(x) sum(is.na(x)))  

max(je$JEDATE)
min(je$JEDATE)


# change column name
#
# 
# je <- rename(je, JENO = 전표번호,
#              DR = 차변금액,
#              CR = 대변금액,
#              ACCTCD = 계정코드,
#              ACCT_NM = 계정과목명)
# 


# A02 Test : Transaction DR/CR
# 
# 
A02 <- je |> 
    select(JENO, DR, CR) |> 
    mutate_all(~replace(., is.na(.), 0)) |> 
    group_by(JENO) |> 
    summarise(DR_sum=sum(DR),
              CR_sum=sum(CR)) |> 
    mutate(Differ= DR_sum - CR_sum)
A02_Differ <- count(A02[A02$Differ > 0, ])


# A03 Test : Trial move Roll-forward Test
# 
# 
CYTB <- read_excel('CYTB.xlsx')
PYTB <- read_excel('PYTB.xlsx')
table(is.na(CYTB))
sapply(CYTB, function(x) sum(is.na(x)))  

CYTB <- drop_na(CYTB, ACCTCD)
PYTB <- drop_na(PYTB, ACCTCD)
CYTB_FP <- CYTB[1:99,]
CYTB_PL <- CYTB[100:length(CYTB$ACCTCD),]
PYTB_FP <- PYTB[1:103,]

tail(CYTB_FP)
head(CYTB_PL)
tail(PYTB_FP)

CYTB_FP <- full_join(CYTB_FP, PYTB_FP, by='ACCTCD') |> 
    mutate_all(~replace(., is.na(.), 0)) |> 
    mutate(move = (DRSUM.x - CRSUM.x) -(DRSUM.y - CRSUM.y)) |> 
    select(ACCTCD, move)

CYTB_PL <- CYTB_PL |> 
    mutate(move = (DRSUM - CRSUM)) |> 
    select(ACCTCD, move)

CYTB_move <- bind_rows(CYTB_FP, CYTB_PL)

A03 <- je |> 
    select(ACCTCD, DR, CR) |> 
    mutate_all(~replace(., is.na(.), 0)) |> 
    group_by(ACCTCD) |> 
    summarise(DR_sum=sum(DR),
              CR_sum=sum(CR))

A03$ACCTCD <- as.character(A03$ACCTCD)
A03 <- left_join(A03, CYTB_move, by = 'ACCTCD')


# table(is.na(A03))
# sapply(A03, function(x) sum(is.na(x)))
# 
# A03_NA <- A03[is.na(A03$move),]   
# print(A03_NA)


A03 <- A03 |> mutate_all(~replace(.,is.na(.), 0)) |> 
    mutate(Differ = (DR_sum - CR_sum - move))
A03_Differ <- count(A03[A03$Differ > 0, ])
A03[A03$Differ > 0, ]


# B09 Test : Corresponding Accounts Test
#
# 
Corr_Acc = '40401'
B09_main <- je |> filter(ACCTCD == Corr_Acc) |> 
    select(JENO, ACCTCD)
B09_Corr <- je |> 
    select(JENO, ACCTCD)
B09 <- semi_join(B09_Corr, B09_main, by = 'JENO')
B09 <- B09 |> filter(!is.na(ACCTCD)) |> 
    count(ACCTCD)


# 계정코드에 이름 붙이기
# 
B09_name <- je |> select(ACCTCD, ACCT_NM) # 계정코드 변수명과 계정과목명 변수명 선택
B09_name <- B09_name[-which(duplicated(B09_name$ACCT_NM)),] # 변수 한개를 기준으로 중복 제거
B09 <- left_join(B09, B09_name, by = 'ACCTCD')


# write file 
#
# 
A02 |> write_csv('A02.csv')
A03 |> write_csv('A03.csv')
B09 |> write_csv('B09.csv')
    