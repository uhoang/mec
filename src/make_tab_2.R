source('settings.R')
source('misc/rename_vars.R')
library(ulibs)
library(ggplot2)
library(ggthemes)

# make histogram for distance measures
load('output/gower_mat.RData')


train$cluster[!train$cluster %in% 'No conditions'] <- paste0('Cluster', train$cluster[!train$cluster %in% 'No conditions'] ) 
data <- data.frame(d  = gower_mat[lower.tri(gower_mat)])

ggplot(data, aes(x = d)) + 
geom_histogram(bins = 20, binwidth = .07, color = 'white') +
labs(title = 'Histogram of all pairwise distances between observations') + 
my_theme()

ggsave(filename = 'viz/distance_hist.png', width = 8.5, height = 5)

profile_vars <- c('age_break',
                  paste0('Q_CONDITIONr', c(1:16, 98)),
                  paste0('Q_PREVENTIONr', c(1:17, 98)),
                  paste0('Q_REMEDYr', c(1:16, 98)))

tabs <- rep(list(NA), length(profile_vars))

for (i in 1:length(profile_vars)) {
  temp <- train %>% dplyr::select(one_of(c('cluster', profile_vars[i]))) 
  names(temp)[2] <- 'var'
  if (grepl('Q_REMEDYr', profile_vars[i])) temp <- temp[!is.na(temp$var), ]
  tab <- temp %>% group_by(cluster) %>%
          summarize(prop = mean(var, na.rm = TRUE),  count = sum(var, na.rm = TRUE), total = n())  
  tab$prop <- sprintf('%.2f', tab$prop * 100)
  names(tab)[1] <- 'group'
  tabs[[i]] <- tab
}

names(tabs) <- profile_vars
ntabs <- unique(gsub('r[0-9]*$', '', profile_vars))

hs1 <- createStyle(fgFill = "#DCE6F1", halign = "CENTER", textDecoration = "italic",
                   border = "Bottom")

wb <- createWorkbook()
for (i in 1:length(ntabs)) {
  vars <- grep(ntabs[i], profile_vars, value = TRUE)
  addWorksheet(wb, ntabs[i])
  start_row = 1
  titles <- grep(ntabs[i], q_health_cond_vars, value = TRUE)
  names(titles) <- NULL
  for (j in 1:length(vars)) {
    writeData(wb, ntabs[i], titles[j], startRow = start_row)
    writeData(wb, ntabs[i], tabs[[vars[j]]], startRow = start_row + 1, borders="rows", headerStyle = hs1, borderStyle = "thin")
    start_row = start_row + nrow(tabs[[vars[j]]]) + 3
  }
}

profile_vars <- paste0('Q_STATEMENTSr', c(1:13))
profile_tabs <- rep(list(NA), length(profile_vars))

for (i in 1:length(profile_vars)) {
  temp <- train %>% dplyr::select(one_of(c('cluster', profile_vars[i]))) 
  names(temp)[2] <- 'var'
  tab <- temp %>% group_by(cluster) %>%
          summarize(prop = mean(var, na.rm = TRUE),  total = n())  
  tab$prop <- sprintf('%.2f', tab$prop)
  names(tab)[1] <- 'group'
  profile_tabs[[i]] <- tab
}

names(profile_tabs) <- profile_vars

addWorksheet(wb, 'Q_STATEMENTS')
start_row = 1
titles <- grep('Q_STATEMENTS', q_profile_vars, value = TRUE)
names(titles) <- NULL
for (j in 1:length(profile_vars)) {
  writeData(wb, 'Q_STATEMENTS', titles[j], startRow = start_row)
  writeData(wb, 'Q_STATEMENTS', profile_tabs[[profile_vars[j]]], startRow = start_row + 1, borders="rows", headerStyle = hs1, borderStyle = "thin")
  start_row = start_row + nrow(profile_tabs[[profile_vars[j]]]) + 3
}

cat_vars <- c(paste0('Q_ACTIVITYr', 1:5),
              paste0('Q_PURCHASEr', 1:8), #,
              paste0('Q_FREQUENCYr', 1:8),
              paste0('Q_MEDIAr', 1:18))
cat_tabs <- rep(list(NA), length(cat_vars))
for ( i in 1:length(cat_vars)) {
  temp <- train %>% dplyr::select(one_of(c('cluster', cat_vars[i])))
  names(temp)[2] <- 'var'
  tab <- temp %>% group_by(cluster, var) %>%
          summarize(count = n()) %>%
          mutate(prop = count/sum(count))
  tab$prop <- sprintf('%.2f', tab$prop)
  var <- tolower(gsub('r[0-9]*$', '', cat_vars[i]))
  cat_text <- eval(parse(text = var))
  tab$var <- cat_text[tab$var]
  cat_tabs[[i]] <- tab
}

names(cat_tabs) <- cat_vars
ntabs <- unique(gsub('r[0-9]*$', '', cat_vars))

for (i in 1:length(ntabs)) {
  vars <- grep(ntabs[i], cat_vars, value = TRUE)
  addWorksheet(wb, ntabs[i])
  start_row = 1
  titles <- grep(ntabs[i], q_cat_vars, value = TRUE)
  names(titles) <- NULL
  for (j in 1:length(vars)) {
    writeData(wb, ntabs[i], titles[j], startRow = start_row)
    writeData(wb, ntabs[i], cat_tabs[[vars[j]]], startRow = start_row + 1, borders="rows", headerStyle = hs1, borderStyle = "thin")
    start_row = start_row + nrow(cat_tabs[[vars[j]]]) + 3
  }
}


demo_vars <- c(
  'Q_GOALS',
  'Q_SPEND',
  'Q_COMMUNITY',
  'Q_GENDER',
  'Q_PARENTS',
  'h_AGE',
  # 'Q_LANGUAGE',
  'h_PROVINCE'
)

demo_tabs <- rep(list(NA), length(demo_vars))

for ( i in 1:length(demo_vars)) {
  temp <- train %>% dplyr::select(one_of(c('cluster', demo_vars[i])))
  names(temp)[2] <- 'var'
  tab <- temp %>% group_by(cluster, var) %>%
          summarize(count = n()) %>%
          mutate(prop = count/sum(count))
  tab$prop <- sprintf('%.2f', tab$prop)
  var <- tolower(gsub('r[0-9]*$', '', demo_vars[i]))
  demo_text <- eval(parse(text = var))
  tab$var <- demo_text[tab$var]
  demo_tabs[[i]] <- tab
}

names(demo_tabs) <- demo_vars


addWorksheet(wb, 'Q_DEMO')
start_row = 1
for (j in 1:length(demo_vars)) {
  writeData(wb, 'Q_DEMO', demo_vars[j], startRow = start_row)
  writeData(wb, 'Q_DEMO', demo_tabs[[demo_vars[j]]], startRow = start_row + 1, borders="rows", headerStyle = hs1, borderStyle = "thin")
  start_row = start_row + nrow(demo_tabs[[demo_vars[j]]]) + 3
}

saveWorkbook(wb, 'output/health_condition_tabs.xlsx', overwrite = TRUE)


temp <- train %>%
        group_by(cluster) %>%
        summarize(count = n()) %>%
        mutate(prop = count/sum(count))


wb <- createWorkbook()
addWorksheet(wb, 'overall_proportion')
start_row = 1
writeData(wb, 'overall_proportion', temp, startRow = 1, borders = 'rows', headerStyle = hs1, borderStyle = 'thin')
saveWorkbook(wb, 'output/overall_proportion.xlsx', overwrite = TRUE)t