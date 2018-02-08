set.seed(168) # for l
source('settings.R')
library(openxlsx)

#### Clean data --------------------------------

data_file <- list.files(data_path, pattern = 'centrum', full.names = TRUE)
  
train <- read.xlsx(data_file, sheet = 1)

#### Data quality checks
# look at the distribution of time completion in secs
# summary(train$qtime) 

# check for respondent status 1(Terminated), 2(Overquota), 3(Qualified), 4(Partial)
# table(train$status, useNA = 'ifany')

# check whether or not the response is real interview
# table(train$vtest, useNA = 'ifany')

# check for age screening 18-70
# table(train$Q_AGESCREENERr1, useNA = 'ifany')

#### Age encoding 
train$age_break <- ifelse(is.na(train$Q_AGESCREENERr1), NA, 
                    ifelse(train$Q_AGESCREENERr1 >= 58, 1, 0))              

#### one-hot encoding the conditions and preventions
no_cond_id <- train$Q_CONDITIONr98 %in% 1 & train$Q_PREVENTIONr98 %in% 1

cluster <- rep(NA_character_, nrow(train))
cluster[no_cond_id] <- 'No conditions'

chronic_vars <- paste0('Q_CONDITIONr', c(3, 10, 11, 12, 13, 15))
train$Q_CONDITIONr_chronic <- apply(train[ , chronic_vars], 1, function(x) as.numeric(any(x == 1)))

pain_vars <- paste0('Q_CONDITIONr', c(5, 14))
train$Q_CONDITIONr_pain <- apply(train[ , pain_vars], 1, function(x) as.numeric(any(x == 1))) 

chronic_vars <- paste0('Q_PREVENTIONr', c(2, 12, 13, 14, 15))
train$Q_PREVENTIONr_chronic <- apply(train[ , chronic_vars], 1, function(x) as.numeric(any(x == 1)))

pain_vars <- paste0('Q_PREVENTIONr', c(3, 16))
train$Q_PREVENTIONr_pain <- apply(train[ , pain_vars], 1, function(x) as.numeric(any(x == 1))) 


#### Calculating distance ------------------------

# vars <- c('age_break', paste0('Q_CONDITIONr', 1:7), paste0('Q_PREVENTIONr', 1:4))
vars <- c('age_break', paste0('Q_CONDITIONr', c(1, 2, 4, 5, 6, 7, 8, 9, 16, '_chronic', '_pain')), 
                       paste0('Q_PREVENTIONr', c(1, 2, 4, 5, 6, 7, 8 , 9, 10, 11, '_chronic','_pain')))

# To remove the missing values returned by gower distance due to all conditions and
# preventions are not selected. When the variable is an asymmetric variable, negative pairs are neglete
# Remove all records that no conditions or preventions is selected. Its rationale is to avoid missing 
# values returned gower distance due to all pairs of negative values are discard for asymmetric variables
added_no_cond_id <- apply(train[ , grep('Q_', vars, value = TRUE)], 1, function(x) all(x == 0))

# vars <- c('age_break', paste0('Q_CONDITIONr', 1:16), paste0('Q_PREVENTIONr', 1:17))
# vars <- c(paste0('Q_CONDITIONr', 1:16), paste0('Q_PREVENTIONr', 1:17))
temp_train <- train[!no_cond_id & ! added_no_cond_id, vars]
cluster[no_cond_id | added_no_cond_id] <- 'No conditions'

# 8 health conditions (Presence/Absence) and 8 health
# preventions (Presence/Absence) are first convertd into 
# 16 binary columns and then the Dice coefficient is used

# train$Q_CONDITIONr17 <- apply(temp_train[paste0('Q_CONDITIONr', 8:16)], 1, function(x) any(x == 1))
# train$Q_PREVENTIONr18 <- apply(train[paste0('Q_PREVENTIONr', 5:17)], 1, function(x) any(x == 1))

# temp_train <- temp_train[apply(temp_train[ , vars], 1, function(x) any(x == 1)), ]
# temp_train <- sapply(temp_train, 2, function(x) ifelse(x == 1, TRUE, FALSE))

# 8 health conditions (presence/Absence) and  health
# preventions (presence/absence) are first coverted into
# 16 binary columns and then Dice coefficicent is used
# train$Q_CONDITIONr17 <- apply(temp_train[paste0('Q_CONDTIONr', 8:16)], 1, function(x) any(x == 1))
# train$Q_PREVENTIONr18 <- apply(train[pate0('Q_PREVENTIONr', 5:17)], 1, function(x) any(x == 1))
