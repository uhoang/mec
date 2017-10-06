source('src/make_weight.R')
source('misc/rename_vars.R')
source('misc/helper_functions.R')
library(dplyr)
library(tidyr)
library(openxlsx)

ncluster <- train %>% dplyr::select(cluster) %>%
            group_by(cluster) %>%
            summarize(key = 'Total', 
                      type = 'N', 
                      value = n()) %>% 
            rename(group = cluster)
ncluster <- rbind(data.frame(group = 'atotal', 
                            key = 'Total', 
                            type = 'N', 
                            value = 2000),
                  ncluster) %>%
            spread(group, value)

names(ncluster)[3] <- 'Total'

profile_vars <- c(
  paste0('Q_CONDITIONr', c(1:16, 98)),
  paste0('Q_PREVENTIONr', c(1:17, 98)),
  paste0('Q_STATEMENTSr', 1:13),
  'Q_AGESCREENERr1'
)
tabs <- rep(list(NA), length(profile_vars))

prop_factor <- 100
for (i in 1:length(profile_vars)) {
  temp <- train %>% dplyr::select(one_of(c('cluster', profile_vars[i], 'w', 'h_AGE', 'h_PROVINCE'))) 
  names(temp)[2] <- 'var'
  sig_pairs_95 <- get_sig_pairs(temp, as.formula('var ~ cluster + h_AGE + h_PROVINCE'))
  sig_pairs_90 <- get_sig_pairs(temp, as.formula('var ~ cluster + h_AGE + h_PROVINCE'), conf.level = .9)
  temp2 <- temp
  temp2$cluster <- 'a_total'
  temp <- rbind(temp2, temp)
  tab <- temp %>% 
          group_by(cluster) %>%
          summarize(
                    key = profile_vars[i],
                    count = sum(var, na.rm = TRUE),
                    unweighted_prop = mean(var, na.rm = TRUE),
                    unweighted_se = sd(var, na.rm = TRUE)/sqrt(length(var)),
                    weighted_prop = weighted.mean(var, w, na.rm = TRUE),
                    weighted_se = weighted.se(var, w, na.rm = TRUE))
  if (grepl('Q_STATEMENTS|Q_AGESCREENER', profile_vars[i])) prop_factor <- 1
  tab[ , 4:ncol(tab)] <- sapply(tab[ , 4:ncol(tab)], function(x) sprintf('%2.2f', x*prop_factor))
  names(tab)[1] <- 'group'
  tab <- tab %>% gather(type, value, -group, -key) %>% spread(group, value)
  names(tab)[3] <- 'Total'
  test_tab <- tab[1:2, ]
  test_tab$type <- c('95% FWCL', '90% FWCL')
  test_tab[1, paste0('Cluster', 1:7)] <- sig_pairs_95 
  test_tab[2, paste0('Cluster', 1:7)] <- sig_pairs_90
  test_tab$Total <- ''
  tab <- rbind(test_tab, tab)
  tabs[[i]] <- tab
}

tabs <- lapply(tabs, function(x) as.data.frame(x))
tabs <- do.call(rbind, tabs)

unique_q <- unique(gsub('r[0-9]*$', '', tabs$key))
unique_q <- unique_q[!unique_q %in% '']


hs1 <- createStyle(fgFill = "#DCE6F1", halign = "CENTER", textDecoration = "italic",
                   border = "Bottom")

wb <- createWorkbook()
addWorksheet(wb, 'health_outlook')
start_row <- 1
for (qn in unique_q[-length(unique_q)]) {
  print(qn)
  q_options <- eval(parse(text = tolower(qn)))
  idx <- grep(qn, tabs$key)
  temp <- tabs[idx, ]
  var <- eval(parse(text = paste0(tolower(qn))))
  temp$key <- var[temp$key]
  if (grepl('Q_STATEMENTS|Q_AGESCREENER', qn)) {
    # 
    temp <- subset(temp, !type %in% 'count')
    temp$key[!(1:nrow(temp) %% 6 %in% 1)] <- ''
    temp$type <- rep(c('95% FWCL', '90% FWCL', 'Unweighted mean', 'Unweighted SE', 'Weighted mean', 'Weighted SE'))
  } else {
    temp$key[!(1:nrow(temp) %% 7 %in% 1)] <- ''
    temp$type <- rep(c('95% FWCL', '90% FWCL', 'Count', 'Unweighted mean', 'Unweighted SE', 'Weighted mean', 'Weighted SE'))

  }
  # temp <- rbind(tabs[1, ], temp)
  temp <- plyr::rbind.fill(ncluster, temp)
  titles <- questions[grep(qn, names(questions), value = TRUE)]
  names(titles) <- NULL
  writeData(wb, 'health_outlook', titles, startRow = start_row)
  writeData(wb, 'health_outlook', temp, startRow = start_row + 1, borders = 'rows', headerStyle = hs1, borderStyle = 'thin')
  start_row <- start_row + nrow(temp) + 3
}

idx <- grep('Q_AGESCREENERr1', tabs$key)
age_tab <- tabs[idx, ]
saveWorkbook(wb, 'output/results.xlsx', overwrite = TRUE)

remedy_var <- c(
  paste0('Q_REMEDYr', c(1:16, 98))
)

tabs <- rep(list(NA), length(remedy_var))

for (i in 1:length(remedy_var)) {
  temp <- train %>% dplyr::select(one_of(c('cluster', remedy_var[i], 'w', 'h_AGE', 'h_PROVINCE'))) 
  names(temp)[2] <- 'var'
  sig_pairs_95 <- get_sig_pairs(temp, as.formula('var ~ cluster + h_AGE + h_PROVINCE'), n_group = 6)
  sig_pairs_90 <- get_sig_pairs(temp, as.formula('var ~ cluster + h_AGE + h_PROVINCE'), conf.level = .9, n_group = 6)
  if (grepl('Q_REMEDYr', remedy_var[i])) temp <- temp[!is.na(temp$var), ]
  temp2 <- temp
  temp2$cluster <- 'a_total'
  temp <- rbind(temp2, temp)
  tab <- temp %>% group_by(cluster) %>%
          summarize(
                    key = remedy_var[i],
                    total = n(),
                    count = sum(var, na.rm = TRUE),
                    unweighted_prop = mean(var, na.rm = TRUE),
                    unweighted_se = sd(var, na.rm = TRUE)/sqrt(length(var)),
                    weighted_prop = weighted.mean(var, w, na.rm = TRUE),
                    weighted_se = weighted.se(var, w, na.rm = TRUE))
          
  tab[ , 5:ncol(tab)] <- sapply(tab[ , 5:ncol(tab)], function(x) sprintf('%2.2f', x*100))
  names(tab)[1] <- 'group'
  tab <- tab %>% gather(type, value, -group, -key) %>% spread(group, value)
  names(tab)[3] <- 'Total'
  test_tab <- tab[1:2, ]
  test_tab$type <- c('95% FWCL', '90% FWCL')
  test_tab[1, paste0('Cluster', 1:6)] <- sig_pairs_95 
  test_tab[2, paste0('Cluster', 1:6)] <- sig_pairs_90
  # test_tab$key <- ''
  test_tab$Total <- ''
  tab <- rbind(test_tab, tab)
  tabs[[i]] <- tab
}


tabs <- lapply(tabs, function(x) as.data.frame(x))
tabs <- do.call(rbind, tabs)

tabs$key <- q_remedy[match(tabs$key, names(q_remedy))]
tabs$key[1:nrow(tabs) %% 4 %in% c(0,2,3)] <- ''
tabs$type <- rep(c('95% FWCL', '90% FWCL', 'Count', 'Total','Unweighted mean', 'Unweighted SE', 'Weighted mean', 'Weighted SE'))
titles <- questions[grep('Q_REMEDY', names(questions), value = TRUE)]
names(titles) <- NULL
writeData(wb, 'health_outlook', titles, startRow = start_row)
writeData(wb, 'health_outlook', tabs, startRow = start_row + 1, borders = 'rows', headerStyle = hs1, borderStyle = 'thin')

start_row <- start_row + nrow(temp) + 3

saveWorkbook(wb, 'output/results.xlsx', overwrite = TRUE)


cat_vars <- c(paste0('Q_ACTIVITYr', 1:5),
              paste0('Q_PURCHASEr', 1:8), #,
              paste0('Q_FREQUENCYr', 1:8),
              paste0('Q_MEDIAr', 1:18))
cat_tabs <- rep(list(NA), length(cat_vars))


for ( i in 1:length(cat_vars)) {
  temp <- data.frame(group = train$cluster, 
                    one_hot_encode(train[ , cat_vars[i]]), 
                    w = train$w,
                    h_AGE = train$h_AGE,
                    h_PROVINCE = train$h_PROVINCE) 
  varnames <- grep('var', names(temp), value = TRUE)
  ttab <- lapply(varnames, function(x) {
    temp_data <- temp[ , c('group', x, 'h_AGE', 'h_PROVINCE')]
    names(temp_data)[2] <- 'var'
    sig_pairs_95 <- get_sig_pairs(temp_data, as.formula('var ~ group + h_AGE + h_PROVINCE'), group_name = 'group')
    sig_pairs_90 <- get_sig_pairs(temp_data, as.formula('var ~ group + h_AGE + h_PROVINCE'), group_name = 'group', conf.level = .9)
    return(rbind(sig_pairs_95, sig_pairs_90))
  })
  names(ttab) <- varnames
  temp$h_AGE <- NULL
  temp$h_PROVINCE <- NULL
  temp <- temp %>%
          gather(key, value, -group, -w)
  temp2 <- temp
  temp2$group <- 'a_total'  
  temp <- rbind(temp2, temp)
  tab <- temp %>% group_by(group, key) %>%
          summarize(option = cat_vars[i],
                    count = sum(value, na.rm = TRUE),
                    unweighted_prop = mean(value, na.rm = TRUE), 
                    unweighted_se = sd(value, na.rm = TRUE)/sqrt(length(value)),
                    weighted_prop = weighted.mean(value, w, na.rm = TRUE),
                    weighted_se = weighted.se(value, w, na.rm = TRUE)) 

  tab[ , 5:ncol(tab)] <- sapply(tab[ , 5:ncol(tab)], function(x) sprintf('%2.2f', x * 100))
  tab <- tab %>% gather(type, value, -group, -key, -option) %>% spread(group, value)
  tablist <- lapply(varnames, function(x) {
    temp_tab <- tab[tab$key %in% x, ]
    test_tab <- temp_tab[1:2, ]
    test_tab$type <- c('95% FWCL', '90% FWCL')
    test_tab$a_total <- ''
    test_tab[ , paste0('Cluster', 1:7)] <- ttab[[x]]
    test_tab <- rbind(test_tab, temp_tab)
    return(test_tab)
  })
  tab <- do.call(rbind, tablist)
  var <- gsub('r[0-9]*$', '', cat_vars[i])
  cat_text <- eval(parse(text = tolower(var)))
  tab$key <- cat_text[gsub('var', '', tab$key)]
  names(tab)[4] <- 'Total'
  cat_tabs[[i]] <- tab
}

cat_tabs <- lapply(cat_tabs, function(x) as.data.frame(x))
cat_tabs <- do.call(rbind, cat_tabs)
unique_q <- unique(gsub('r[0-9]*$', '', cat_tabs$option))

addWorksheet(wb, 'profile')
start_row <- 1
for (qn in unique_q) {
  print(qn)
  q_options <- eval(parse(text = tolower(qn)))
  idx <- grep(qn, cat_tabs$option)
  temp <- cat_tabs[idx, ]
  temp$key[!(1:nrow(temp) %% 7 %in% 1)] <- ''
  temp$type <- rep(c('95% FWCL', '90% FWCL', 'Count', 'Unweighted mean', 'Unweighted SE', 'Weighted mean', 'Weighted SE'))
  temp <- plyr::rbind.fill(ncluster[1, ], temp)
  title <- questions[grep(qn, names(questions), value = TRUE)]
  sub_title <- eval(parse(text = paste0(tolower(qn), '_title')))
  temp$option <- sub_title[temp$option]
  temp$option[duplicated(temp$option)] <- ''
  temp <- data.frame(option = temp[ , ncol(temp)], temp[ , -ncol(temp)])
  names(titles) <- NULL
  writeData(wb, 'profile', title, startRow = start_row)
  writeData(wb, 'profile', temp, startRow = start_row + 2, borders = 'rows', headerStyle = hs1, borderStyle = 'thin')
  start_row <- start_row + nrow(temp) + 4
}

saveWorkbook(wb, 'output/results.xlsx', overwrite = TRUE)


demo_vars <- c(
  'Q_GOALS',
  'Q_SPEND',
  'Q_COMMUNITY',
  'Q_GENDER',
  'Q_PARENTS',
  # 'h_AGE',
  # 'Q_LANGUAGE',
  'Q_PROVINCE'
)

demo_tabs <- rep(list(NA), length(demo_vars))


for ( i in 1:length(demo_vars)) {
  print(demo_vars[i])
  temp <- data.frame(group = train$cluster, 
                    one_hot_encode(train[ , demo_vars[i]]), 
                    w = train$w,
                    h_AGE = train$h_AGE,
                    h_PROVINCE = train$h_PROVINCE) 
  varnames <- grep('var', names(temp), value = TRUE)
  ttab <- lapply(varnames, function(x) {
    temp_data <- temp[ , c('group', x, 'h_AGE', 'h_PROVINCE')]
    names(temp_data)[2] <- 'var'
    sig_pairs_95 <- get_sig_pairs(temp_data, as.formula('var ~ group + h_AGE + h_PROVINCE'), group_name = 'group')
    sig_pairs_90 <- get_sig_pairs(temp_data, as.formula('var ~ group + h_AGE + h_PROVINCE'), group_name = 'group', conf.level = .9)
    return(rbind(sig_pairs_95, sig_pairs_90))
  })
  names(ttab) <- varnames
  temp$h_AGE <- NULL
  temp$h_PROVINCE <- NULL
  temp <- temp %>%
          gather(key, value, -group, -w)
  temp2 <- temp
  temp2$group <- 'a_total'
  temp <- rbind(temp2, temp)
  tab <- temp %>% group_by(group, key) %>%
          summarize(option = demo_vars[i],
                    count = sum(value, na.rm = TRUE),
                    unweighted_prop = mean(value, na.rm = TRUE), 
                    unweighted_se = sd(value, na.rm = TRUE)/sqrt(length(value)),
                    weighted_prop = weighted.mean(value, w, na.rm = TRUE),
                    weighted_se = weighted.se(value, w, na.rm = TRUE)) 

  tab[ , 5:ncol(tab)] <- sapply(tab[ , 5:ncol(tab)], function(x) sprintf('%2.2f', x * 100))
  tab <- tab %>% gather(type, value, -group, -key, -option) %>% spread(group, value)
  tablist <- lapply(varnames, function(x) {
    temp_tab <- tab[tab$key %in% x, ]
    test_tab <- temp_tab[1:2, ]
    test_tab$type <- c('95% FWCL', '90% FWCL')
    test_tab$a_total <- ''
    test_tab[ , paste0('Cluster', 1:7)] <- ttab[[x]]
    test_tab <- rbind(test_tab, temp_tab)
    return(test_tab)
  })
  tab <- do.call(rbind, tablist)
  var <- gsub('r[0-9]*$', '', demo_vars[i])
  demo_text <- eval(parse(text = tolower(var)))
  tab$key <- demo_text[gsub('var', '', tab$key)]
  names(tab)[4] <- 'Total'
  demo_tabs[[i]] <- tab
}

demo_tabs <- lapply(demo_tabs, function(x) as.data.frame(x))
demo_tabs <- do.call(rbind, demo_tabs)
unique_q <- unique(gsub('r[0-9]*$', '', demo_tabs$option))

addWorksheet(wb, 'profile2')
start_row <- 1
for (qn in unique_q) {
  print(qn)
  idx <- grep(qn, demo_tabs$option)
  temp <- demo_tabs[idx, ]
  temp$key[!(1:nrow(temp) %% 7 %in% 1)] <- ''
  temp$type <- rep(c('95% FWCL', '90% FWCL', 'Count', 'Unweighted mean', 'Unweighted SE', 'Weighted mean', 'Weighted SE'))
  temp <- plyr::rbind.fill(ncluster[1, ], temp)
  title <- questions[grep(qn, names(questions), value = TRUE)]
  temp$option <- NULL
  names(titles) <- NULL
  writeData(wb, 'profile2', title, startRow = start_row)
  writeData(wb, 'profile2', temp, startRow = start_row + 2, borders = 'rows', headerStyle = hs1, borderStyle = 'thin')
  start_row <- start_row + nrow(temp) + 4
}

saveWorkbook(wb, 'output/results.xlsx', overwrite = TRUE)


for (qn in 'Q_AGESCREENERr1') {
  print(qn)
  if (grepl('Q_STATEMENTS|Q_AGESCREENER', qn)) {
    age_tab <- subset(age_tab, !type %in% 'count')
    age_tab$key[!(1:nrow(age_tab) %% 6 %in% 1)] <- ''
    age_tab$type <- rep(c('95% FWCL', '90% FWCL', 'Unweighted mean', 'Unweighted SE', 'Weighted mean', 'Weighted SE'))
  } else {
    age_tab$key[!(1:nrow(age_tab) %% 7 %in% 1)] <- ''
    age_tab$type <- rep(c('95% FWCL', '90% FWCL', 'Count', 'Unweighted mean', 'Unweighted SE', 'Weighted mean', 'Weighted SE'))

  }
  # age_tab <- plyr::rbind.fill(ncluster, age_tab)
  titles <- questions[grep(qn, names(questions), value = TRUE)]
  names(titles) <- NULL
  writeData(wb, 'profile2', titles, startRow = start_row)
  writeData(wb, 'profile2', age_tab, startRow = start_row + 1, borders = 'rows', headerStyle = hs1, borderStyle = 'thin')
  start_row <- start_row + nrow(age_tab) + 3
}

saveWorkbook(wb, 'output/results.xlsx', overwrite = TRUE)
