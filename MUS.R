## 매출액 MUS(Monetary Unit Selection) Sampling

## MUS sampling 함수 생성
mus_sampling <- \(SR, RC, PL, PM, EA, pop, am){
  
  # mus_sampling 함수 실행을 위하여 금액 열 이름을 amount로 변경.
  if(am != 'amount'){
    pop <- pop %>% 
      rename('amount' = all_of(am))
  }
  
    ## Assurance Factor 산정
    
    assurance_factor_raw <- tibble::tribble(
        ~Significant.Risk, ~Reliance.on.Controls, ~High, ~Moderate, ~Low, ~Analytical.Procedures.Not.Performed,
                    "Yes",                  "No",   1.1,       1.6,  2.8,                                    3,
                     "No",                  "No",     0,       0.5,  1.7,                                  1.9,
                    "Yes",                 "Yes",     0,       0.2,  1.4,                                  1.6,
                     "No",                 "Yes",     0,         0,  0.3,                                  0.5
        )
    
    assurance_factor <- assurance_factor_raw %>% 
        pivot_longer(
        cols = c(High, Moderate, Low, Analytical.Procedures.Not.Performed),
        names_to = "Planned_Level",  # Planned Level of Assurance from Substantive Analytical Procedures
        values_to = "Assurance_Factor"
        )
    
    assurance_factor <- assurance_factor %>%
        filter(
            Significant.Risk == SR,
            Reliance.on.Controls == RC,
            Planned_Level == PL
        )
    AF <- assurance_factor[[1,4]]
    
    ## Sampling Interval = (Tolerable Misstatement – Expected Misstatement) / Assurance Factor
    sampling_interval = (PM - EA) / AF
    
    ## Consideration of Zero or Negative Amounts
    pop <- pop %>% 
      filter(amount > 0)
    
    ## High Value
    high_value_items <- pop %>% 
      filter(amount >= PM)
    
    pop_remain <- pop %>% 
      filter(amount < PM)
    
    ## Expected Sample Size = (Population Subject to Sampling X Assurance Factor) / (Tolerable Misstatement – Expected Misstatement)
    pop_amount <- pop_remain$amount %>% sum()
    sample_size <- round(pop_amount * AF / (PM- EA))
    
    sampling_row <- seq(sample_size)    
    sampling_n <- seq(sample_size) * sampling_interval
    
    pop_remain <- pop_remain %>% 
        mutate(cum = cumsum(amount))
    
    for (i in seq_along(sampling_n)) {
        sampling_row[i] <- which(pop_remain$cum > sampling_n[i])[1]
    }
    
    sampling_row <- sampling_row %>% unique()
    
    ## 샘플링 객체 생성
    sampling_remain <- pop_remain %>% 
      select(-cum) %>% 
      slice(sampling_row)
    
    sampling <<- high_value_items %>% 
      bind_rows(sampling_remain)
}

# Parameters Setting

SR <- "Yes"         ## or  "No"
RC <- "Yes"         ## or  "No"
PL <- "Analytical.Procedures.Not.Performed"     ## or  "High", "Low", "Moderate"
am <- "CR"          ## 금액열 지정

## 수행중요성 금액 및 허용오류율(5% 등) 입력
PM <- 700000000     ## Tolerable misstatement (generally performance materiality)
EA <- PM * 0.05    ## Expected misstatement


# 모집단 filter 및 Sampling 수행

## Population
acc <- c("40100", "40401", "40700", "41100", "41200")  # 총 매출 계정 모음

pop <- je_tbl %>% 
  filter(ACCTCD %in% acc) %>% 
  mutate(JENO = as.character(JENO))

## 함수 실행
mus_sampling(SR, RC, PL, PM, EA, pop, am) # pop : 샘플링 대상 모집단

## 샘플링 내역 확인
print(sampling, n = Inf)

## 추출된 샘플 엑셀 파일 생성
sampling %>% write_xlsx("sample.xlsx")



