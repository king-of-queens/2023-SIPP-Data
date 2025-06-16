##Exploratory Analysis of 2023 SIPP Data with replicate weights attached
#setting my working directory
setwd("C:\\Users\\samue\\Desktop\\2023 SIPP Project")
library(tidyverse)
library(janitor)

##Data READIN VALIDATION
SIPP_Combined_2023 <- read_delim("C:\\Users\\samue\\Desktop\\2023 SIPP Project\\SIPP_combined_2023.csv")

# SIPP data are in person-month format, meaning each record represents one month for a specific person.
#   Unique persons are identified using SSUID+PNUM. 
#   Unique households are identified using SSUID+ERESIDENCEID.
#   For additional guidance on using SIPP data, please see the SIPP Users' Guide at <https://www.census.gov/programs-surveys/sipp/guidance/users-guide.html>
SIPP_Combined_2023 %>% 
  tabyl(SPANEL, MONTHCODE)

##DATA FORMATTING
#deduplicating and grouping data points to find unique persons
Person_SIPP_2023 <- SIPP_Combined_2023 %>%
  mutate(PNUM = as.character(PNUM)) %>% 
  mutate(unique_ID = paste(SSUID, PNUM)) %>% 
  select(unique_ID, everything())

nrow(distinct(Person_SIPP_2023, unique_ID))

Person_SIPP_2023 <- Person_SIPP_2023 %>% 
  distinct(unique_ID, .keep_all = TRUE)

###just wanting to save my work
Person_SIPP_2023 %>% 
  write_delim("unique_person_SIPP_2023.csv", col_names = TRUE, append = FALSE)

#more filtering of household data to grab the sample population I am interested in, formatting as well
Person_SIPP_2023 <- Person_SIPP_2023 %>% 
  #removing all NA from income and education variables, selecting only positive income, and selecting ages from 18-64
  mutate(across(c(ESEX, EEDUC, ERACE, EORIGIN, EMS, TLIVQTR, EPROCERT, RMESR), factor)) %>% 
  #I am turning the sex and education variables (may add others...) into factors and recoding them
  mutate(sex = fct_recode(ESEX,
                          "Male" = "1",
                          "Female" = "2"), .keep = "unused") %>% 
  mutate(education_level = fct_recode(EEDUC,
                                      "Less than High School Diploma" = "31",
                                      "Less than High School Diploma" = "32",
                                      "Less than High School Diploma" = "33",
                                      "Less than High School Diploma" = "34",
                                      "Less than High School Diploma" = "35",
                                      "Less than High School Diploma" = "36",
                                      "Less than High School Diploma" = "37",
                                      "Less than High School Diploma" = "38",
                                      "High School Graduate (diploma/GED/Equivalent)" = "39",
                                      "Some college credit, no degree" = "40",
                                      "Some college credit, no degree" = "41",
                                      "Associate’s degree" = "42",
                                      "Bachelor's degree" = "43",
                                      "Master's degree" = "44",
                                      "Professional School degree" = "45",
                                      "Doctorate degree" = "46")) %>%
  mutate(education_type = fct_collapse(EEDUC,
                                       "Less than HS Diploma" = c("31", "32", "33", "34", "35", "36", "37", "38"),
                                       "Above HS Diploma" = c("40", "41", "42", "43", "44", "45", "46"),
                                       "High School Diploma/Equivalent" = "39"), .keep = "unused") %>%
  mutate(race = fct_recode(ERACE,
                           "White" = "1",
                           "Black" = "2",
                           "Asian" = "3",
                           "Other" = "4"), .keep = "unused") %>% 
  mutate(hisp_origin = fct_recode(EORIGIN,
                                  "yes" = "1",
                                  "no" = "2"), .keep = "unused") %>% 
  mutate(martial_status = fct_recode(EMS,
                                     "Married" = "1",
                                     "Married" = "2",
                                     "Widowed" = "3",
                                     "Divorced" = "4",
                                     "Separated" = "5",
                                     "Never Married" = "6"), .keep = "unused") %>% 
  mutate(living_quarters = fct_recode(TLIVQTR,
                                      "House, Apartment, Flat" = "1",
                                      "Mobile Home, Rooming House, Other" = "2",
                                      "Group Quarters/Non-permanent Residence" = "3"), .keep = "unused") %>% 
  mutate(license_or_cert = fct_recode(EPROCERT,
                                      "yes" = "1",
                                      "no" = "2"), .keep = "unused") %>%
  mutate(empstatus = fct_collapse(RMESR,
                                  "Employed" = c("1", "2", "3", "4", "5"),
                                  "Unemployed" = c("6", "7", "8"), other_level = NULL), .keep = "unused") %>% 
  select(unique_ID, sex, education_level, education_type, race, hisp_origin, living_quarters, license_or_cert, 
         martial_status, living_quarters, empstatus, TPTOTINC, everything())

Person_SIPP_2023 <- Person_SIPP_2023 %>%
  rename(monthly_income = TPTOTINC) %>% 
  filter(monthly_income > 0, !is.na(education_level)) %>% 
  mutate(log_monthly_income = log(monthly_income))

###just wanting to save my work
Person_SIPP_2023 %>% 
  write_delim("unique_person_SIPP_2023.csv", col_names = TRUE, append = FALSE)