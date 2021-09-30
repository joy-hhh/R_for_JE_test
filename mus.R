library(tidyverse)

je <- read_csv("~/R/R_for_JE_test/je_utf.csv")
sales <- filter(je, ACCTCD == 40401)


pm <- 300000000
amount = "CR"


first_pm <- pm
sampling <- vector()
for (i in seq_along(sales$CR)) {
  if (pm - sales[i, amount] >0) { 
    pm = pm - sales[i, amount]
  } else { 
    pm = pm - sales[i, amount] + first_pm
    sampling <- c(sampling, i)
  }
}

test_sample <- sales[sampling,]

