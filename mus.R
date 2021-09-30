library(tidyverse)


je <- read_csv("~/R/R_for_JE_test/je_utf.csv")
sales <- filter(je, ACCTCD == 40401)


pm <- 300000000
# rename(je, CR = 금액열이름)


first_pm <- pm
sampling <- vector()
for (i in seq_along(sales$CR)) {
  if (pm - sales[i, "CR"] >0) { 
    pm = pm - sales[i, "CR"]
  } else { 
    pm = pm - sales[i, "CR"] + first_pm
    sampling <- c(sampling, i)
  }
}


test_sample <- sales[sampling,]
write_excel_csv(test_sample, "test_sample.csv")
