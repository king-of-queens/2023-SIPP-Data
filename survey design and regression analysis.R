#setting my working directory
setwd("C:\\Users\\samue\\Desktop\\2023 SIPP Project")
library(tidyverse)
library(survey)
library(fastDummies)
library(stargazer)

##SKIP THIS SECTION, only for additional formatting that I didnt realize I needed right away (go to survey regression set up section)
Person_SIPP_2023 <- read_delim("unique_person_SIPP_2023.csv")

person_repweights <- Person_SIPP_2023 %>% 
  select(unique_ID, REPWGT0:REPWGT240)

Person_SIPP_2023 <- Person_SIPP_2023 %>% 
  dummy_cols(select_columns = "education_type")

Person_SIPP_2023 <- Person_SIPP_2023 %>% 
  dummy_cols(select_columns = "sex")

Person_SIPP_2023 %>% 
  janitor::tabyl(TAGE)

Person_SIPP_2023 %>% 
  janitor::tabyl(`education_type_Above HS Diploma`)

Person_SIPP_2023 <- Person_SIPP_2023 %>% 
  filter(!is.na(education_type), TAGE >= 18, TAGE <= 64)

###just wanting to save my work
Person_SIPP_2023 %>% 
  write_delim("regression_ready_unique_person_SIPP_2023.csv", col_names = TRUE, append = FALSE)

###Setting Up Survey Design with survey package (using Fays adjusted BRR)
Person_SIPP_2023 <- read_delim("regression_ready_unique_person_SIPP_2023.csv")

summary(Corrected_Person_SIPP_2023$education_type)

Person_SIPP_2023 %>% 
  filter(monthly_income > 100 & monthly_income < 150000) %>% 
  ggplot(data = .) +
  geom_histogram(mapping = aes(x = log_monthly_income), bins = 50)

Filtered_Person_SIPP_2023 %>% 
  summary(monthly_income)
  
Filtered_Person_SIPP_2023 %>% 
  write_delim("filtered_regression_ready_SIPP_2023.csv", col_names = TRUE, append = FALSE)

sipp_design <- svrepdesign(
  data = Person_SIPP_2023,
  type = "Fay",
  repweights = "REPWGT[0-9]+",
  weights = ~WPFINWGT,
  combined.weights = TRUE,
  rho = 0.5,
  mse = TRUE
)

sipp_design1 <- svrepdesign(
  data = Filtered_Person_SIPP_2023,
  type = "Fay",
  repweights = "REPWGT[0-9]+",
  weights = ~WPFINWGT,
  combined.weights = TRUE,
  rho = 0.5,
  mse = TRUE
)

summary(sipp_design)

##Survey Weighted Regression (trying to replicate the Mincer earnings equation)
Weighted_OLS_model <- svyglm(log_monthly_income ~ `education_type_Above HS Diploma` + TAGE + I(TAGE^2),
                    design = sipp_design1)
broom::tidy(Weighted_OLS_model)
broom::glance(Weighted_OLS_model)

##Comparing weighted vs unweighted models
Unweighted_OLS_model <- lm(log_monthly_income ~ `education_type_Above HS Diploma` + TAGE + I(TAGE^2),
                           data = Person_SIPP_2023)
broom::tidy(Unweighted_OLS_model)
broom::glance(Unweighted_OLS_model)

stargazer(Unweighted_OLS_model, Weighted_OLS_model, type = "text", align = TRUE)

##Similar Regression based on Mincer, but including controls for:
##sex, race, hispanic origin, living quarters, professional license or certification, and employment status
Weighted_OLS_model2 <- svyglm(log_monthly_income ~ `education_type_Above HS Diploma` + TAGE + I(TAGE^2) + sex + race + hisp_origin + living_quarters + license_or_cert +  martial_status + living_quarters + empstatus,
                     design = sipp_design1)
broom::tidy(Weighted_OLS_model2)
broom::glance(Weighted_OLS_model2)

summary(Weighted_OLS_model2)

plot(Weighted_OLS_model2, which = 3)

Filtered_Person_SIPP_2023 %>%
  ggplot(data = .) +
  geom_histogram(mapping = aes(x = log_monthly_income), bins = 50)

confint(Weighted_OLS_model2, "`education_type_Above HS Diploma`", level = 0.95)

model_residuals <- residuals(Weighted_OLS_model2, type = "pearson")
fitted_model_values <- predict(Weighted_OLS_model2)

qqnorm(model_residuals, main = "QQ Plot of Mincer Model Residuals")
qqline(model_residuals, col = "red")