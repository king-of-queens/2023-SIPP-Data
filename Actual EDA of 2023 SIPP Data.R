##Exploratory Analysis of 2023 SIPP Data with replicate weights attached
#setting my working directory
setwd("C:\\Users\\samue\\Desktop\\2023 SIPP Project")
library(tidyverse)
library(janitor)

Person_SIPP_2023 <- read_delim("unique_person_SIPP_2023.csv")

#identifying a trend between education level and total monthly income (starting with household data)
Person_SIPP_2023 %>% 
  ggplot(data = .) +
  geom_boxplot(
    mapping = aes(x = reorder(education_level, log_monthly_income, FUN = median),
                  y = log_monthly_income
    )
  ) +
  coord_flip()

#similar trends when we observe education type and total monthly income
Person_SIPP_2023 %>% 
  ggplot(data = .) +
  geom_boxplot(
    mapping = aes(x = reorder(education_type, log_monthly_income, FUN = median),
                  y = log_monthly_income
    )
  ) +
  coord_flip()

#identifying a slight trend between age and total monthly income  
Person_SIPP_2023 %>% 
  ggplot(data = ., mapping = aes(x = TAGE, y = log_monthly_income)) +
  geom_jitter() +
  geom_smooth(method = "lm")

#looking into covariation between race and income
Person_SIPP_2023 %>% 
  ggplot(data = .) +
  geom_boxplot(
    mapping = aes(x = reorder(race, log_monthly_income, FUN = median),
                  y = log_monthly_income
    )
  ) +
  coord_flip()