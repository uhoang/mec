chronic_vars <- paste0('Q_CONDITIONr', c(3, 10, 11, 12, 13, 15))
train$Q_CONDITIONr_chronic <- apply(train[ , chronic_vars], 1, function(x) as.numeric(any(x == 1)))

pain_vars <- paste0('Q_CONDITIONr', c(5, 14))
train$Q_CONDITIONr_pain <- apply(train[ , pain_vars], 1, function(x) as.numeric(any(x == 1))) 

chronic_vars <- paste0('Q_PREVENTIONr', c(2, 12, 13, 14, 15))
train$Q_PREVENTIONr_chronic <- apply(train[ , chronic_vars], 1, function(x) as.numeric(any(x == 1)))

pain_vars <- paste0('Q_PREVENTIONr', c(3, 16))
train$Q_PREVENTIONr_pain <- apply(train[ , pain_vars], 1, function(x) as.numeric(any(x == 1))) 
