### load library ----

library(readxl)
library(lubridate)
library(tidyverse)

### Obtain data from read file ----
# 
# 
je_raw <- read_csv('je.csv', locale=locale('ko',encoding='euc-kr')) 
je_raw
# View(je_raw)

### Obtain data from read url
#
# je <- read_csv('https://raw.githubusercontent.com/joy-hhh/R_for_JE_test/main/je.csv', locale = locale('ko',encoding = 'cp949'))


### A01 test : Data Integrity ----
# 
# 

je_tbl <- je_raw %>% mutate(JEDATE = ymd(JEDATE))
# je$JEDATE <- ymd(je$JEDATE)

print(je_tbl)
colnames(je_tbl)
str(je_tbl)  
colSums(is.na(je_tbl))
max(je_tbl$JEDATE)
min(je_tbl$JEDATE)
range(je_tbl$JEDATE)


### use package

library(skimr)
skim(je_tbl)
A01 <- skim(je_tbl)


### change column name ----
#
# 
# je <- rename(je, JENO = 전표번호,
#              DR = 차변금액,
#              CR = 대변금액,
#              ACCTCD = 계정코드,
#              ACCT_NM = 계정과목명)
# 


### A02 Test : Transaction DR/CR ----
# 
# 
A02 <- je_tbl %>%  
    select(JENO, DR, CR) %>%  
    mutate_all(~replace(., is.na(.), 0)) %>%  
    group_by(JENO) %>% 
    summarise(DR_sum=sum(DR),
              CR_sum=sum(CR)) %>%  
    mutate(Differ= DR_sum - CR_sum)
A02 %>% filter(Differ != 0) %>% nrow() 


### A03 Test : Trial move Roll-forward Test ----
# 
# 
cytb_raw <- read_excel('CYTB.xlsx')
pytb_raw <- read_excel('PYTB.xlsx')
colSums(is.na(cytb_raw))
colSums(is.na(pytb_raw))

### split BS, PL from account name
#
#
# cytb_raw <- read_excel("data/je/CYTB.xlsx")
# 
# cytb_tbl <- cytb_raw %>% 
#     mutate(계정구분 = ifelse(str_detect(계정과목, pattern =  "<< 손          익 >>"), "손익계산서", NA)) %>% 
#     fill(계정구분, .direction = "down") %>% 
#     mutate(계정구분 = ifelse(is.na(계정구분), "대차대조표", 계정구분))
# 
# cytb_bs_tbl <-  cytb_tbl %>% 
#     filter(계정구분 == "대차대조표")
# 
# cytb_pl_tbl <-  cytb_tbl %>% 
#     filter(계정구분 == "손익계산서")


cytb_tbl <- drop_na(cytb_raw, ACCTCD)
pytb_tbl <- drop_na(pytb_raw, ACCTCD)


CYTB_FP <- cytb_tbl %>% 
    slice(1:99)
CYTB_PL <- cytb_tbl %>% 
    slice(100:n())
PYTB_FP <- pytb_tbl %>% 
    slice(1:103)


tail(CYTB_FP)
head(CYTB_PL)
tail(PYTB_FP)


CYTB_FP <- full_join(CYTB_FP, PYTB_FP, by='ACCTCD')  %>%  
    mutate_all(~replace(., is.na(.), 0)) %>% 
    mutate(move = (DRSUM.x - CRSUM.x) -(DRSUM.y - CRSUM.y)) %>% 
    select(ACCTCD, move)

CYTB_PL <- CYTB_PL %>% 
    mutate(move = (DRSUM - CRSUM)) %>% 
    select(ACCTCD, move)

CYTB_move <- bind_rows(CYTB_FP, CYTB_PL)

A03 <- je_tbl %>% 
    select(ACCTCD, DR, CR) %>% 
    mutate_all(~replace(., is.na(.), 0)) %>% 
    group_by(ACCTCD) %>% 
    summarise(DR_sum=sum(DR),
              CR_sum=sum(CR)) %>% 
    ungroup() %>%
    # join 할때 자료형 일치
    mutate(ACCTCD = as.character(ACCTCD))

A03 <- left_join(A03, CYTB_move, by = 'ACCTCD')

A03 <- A03 %>% mutate_all(~replace(.,is.na(.), 0)) %>% 
    mutate(Differ = (DR_sum - CR_sum - move))
A03 %>% filter(Differ != 0)



### B09 Test : Corresponding Accounts Test ----
# 
# 
Corr_Acc = '40401'
B09_main <- je_tbl %>% filter(ACCTCD == Corr_Acc) %>% 
    select(JENO, ACCTCD)
B09_Corr <- je_tbl %>% 
    select(JENO, ACCTCD)
B09 <- semi_join(B09_Corr, B09_main, by = 'JENO')
B09 <- B09 %>% filter(!is.na(ACCTCD)) %>% 
    count(ACCTCD)


### 계정코드에 이름 붙이기 ----
# 
B09_name <- je_tbl %>% select(ACCTCD, ACCT_NM) %>% distinct()  # 계정코드 변수명과 계정과목명 변수명 선택
B09 <- left_join(B09, B09_name, by = 'ACCTCD')


### write file ----
#
# 
# A02 %>% write_csv('A02.csv')
# A03 %>% write_csv('A03.csv')
# B09 %>% write_csv('B09.csv')
    