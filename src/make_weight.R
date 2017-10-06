source('misc/make_marginals.R')
source('misc/rename_vars.R')
library(survey)
# library(dplyr)
# library(tidyr)
# load dataset
train <- readRDS('output/train.rds')

train$h_AGE <- h_age[train$h_AGE]

train$h_PROVINCE <- h_province[train$h_PROVINCE]

train$cluster[train$cluster %in% 'No conditions'] <- 'Cluster7'


emp_svy <- svydesign(ids = ~ 1, weights = 1, data = train)

cal_svy <- calibrate(emp_svy, formula = as.formula('~ h_AGE + h_PROVINCE'), 
                    population = pop_prop,
                    calfun = 'raking')

train$w <- weights(cal_svy)

# # svymean(~ h_AGE, cal_svy)
# # svymean(~ h_PROVINCE, cal_svy)

# svyquantile(~ Q_AGESCREENERr1, cal_svy)

# profile_vars <- c(
                  # 'age_break',
