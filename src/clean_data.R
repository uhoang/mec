set.seed(168) # for reproducibility
source('settings.R')

#### Clean data --------------------------------

data_file <- list.files(data_path, pattern = 'centrum', full.names = TRUE)

train <- read.xlsx(data_file, sheet = 1)
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
  
# vars <- c('age_break', paste0('Q_CONDITIONr', 1:16), paste0('Q_PREVENTIONr', 1:17))
# vars <- c(paste0('Q_CONDITIONr', 1:16), paste0('Q_PREVENTIONr', 1:17))
temp_train <- train[!no_cond_id, vars]

# 8 health conditions (Presence/Absence) and 8 health
# preventions (Presence/Absence) are first convertd into 
# 16 binary columns and then the Dice coefficient is used

# train$Q_CONDITIONr17 <- apply(temp_train[paste0('Q_CONDITIONr', 8:16)], 1, function(x) any(x == 1))
# train$Q_PREVENTIONr18 <- apply(train[paste0('Q_PREVENTIONr', 5:17)], 1, function(x) any(x == 1))

# temp_train <- temp_train[apply(temp_train[ , vars], 1, function(x) any(x == 1)), ]
# temp_train <- sapply(temp_train, 2, function(x) ifelse(x == 1, TRUE, FALSE))
