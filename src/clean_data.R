set.seed(168) # for reproducibility
library(dplyr)
library(cluster) # for gower similarity and pam
library(Rtsne) # t-SNE plot
library(ggplot2) # for visualization
library(openxlsx)

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
temp_train <- train[!no_cond_id, vars]

# 8 health conditions (Presence/Absence) and 8 health
# preventions (Presence/Absence) are first convertd into 
# 16 binary columns and then the Dice coefficient is used

# train$Q_CONDITIONr17 <- apply(temp_train[paste0('Q_CONDITIONr', 8:16)], 1, function(x) any(x == 1))
# train$Q_PREVENTIONr18 <- apply(train[paste0('Q_PREVENTIONr', 5:17)], 1, function(x) any(x == 1))

# temp_train <- temp_train[apply(temp_train[ , vars], 1, function(x) any(x == 1)), ]
# temp_train <- sapply(temp_train, 2, function(x) ifelse(x == 1, TRUE, FALSE))

gower_dist <- daisy(temp_train, metric = 'gower')
# gower_dist <- daisy(temp_train, metric = 'gower', type = list(asymm = 1:ncol(temp_train)))

# nvars <- ncol(temp_train[ , vars])


hist(gower_mat[lower.tri(gower_mat)])
# temp_train[, vars[-1]] <- sapply(temp_train[ , vars[-1]], function(x) ifelse(x == 1, TRUE, FALSE))
# temp_train[, vars] <- sapply(temp_train[ , vars], function(x) ifelse(x == 1, TRUE, FALSE))
# gower_dist <- daisy(temp_train[ , vars], metric = 'gower', type = list(asymm =  1:nvars))
# gower_dist <- daisy(temp_train[, vars], metric = 'gower', type = list(asymm = 2:nvars))

# summary(gower_dist)
# gower_dist[is.na(gower_dist)] <- 0

# sanity check, print out the most similar and dissimilar pair
# in the dataset to see if it makes sense
gower_mat <- as.matrix(gower_dist)
# gower_mat[is.na(gower_mat)] <- 0

temp_train[which(gower_mat == min(gower_mat[gower_mat != min(gower_mat)]), arr.ind = TRUE)[1, ], ]
temp_train[which(gower_mat == max(gower_mat[gower_mat != max(gower_mat)]), arr.ind = TRUE)[1, ], ]

# Choosing a clustering alg

# Calculate silhouette width for many k using PAM

sil_width <- c(NA)

for (i in 2:10) {
  pam_fit <- pam(gower_dist, diss = TRUE, k = i)
  sil_width[i] <- pam_fit$silinfo$avg.width
}

# Plot sihouette width (higher is better)
plot(1:10, sil_width, xlab = 'Number of clusters', ylab = 'Silhouette Width')
lines(1:10, sil_width)

# Cluster interpretation via descriptive statistics
pam_fit <- pam(gower_dist, diss = TRUE, k = 6)

cluster[as.numeric(names(pam_fit$clustering))] <- pam_fit$clustering

train$cluster <- cluster

pam_results <- train %>% dplyr::select(dplyr::one_of(c(vars, 'cluster'))) %>%
                         # mutate(cluster = cluster) %>% 
                         group_by(cluster) %>%
                         do(the_summary = summary(.))
pam_results$the_summary

# Via visualization 


gower_dist2 <- daisy(train[ , vars], metric = 'gower')

tsne_obj <- Rtsne(gower_dist2, is_distance = TRUE)
tsne_data <- tsne_obj$Y %>% data.frame() %>% 
            setNames(c('X', 'Y')) %>% 
            mutate(cluster = factor(train$cluster))


ggplot(aes(x = X, y = Y), data = tsne_data) + geom_point(aes(color = cluster))


# Test stability of clusters using bootstrap
# clusterboot(gower_dist, B = 10)
cf <- clusterboot(gower_dist, B = 100, 
                  bootmethod = c('boot'), 
                  clustermethod = claraCBI,
                  k = 6, seed = 12345)

#   Do the clustering. 
pfit <- hclust(gower_mat, method="ward")   

# > cf$bootmean
# [1] 0.8642140 0.7106713 0.6741667 0.7403177 0.7828143 0.7764324
# the observations in cluster 1 have highly similar health condition and prevention,
# distinct from those of the other cluster

# we can also say that the individuals in cluster 2-6 represent distinct health behaviours/patterns
# but there isn't high certainty about which points should be clustered together.

# number of times each cluster was dissolved. Clusters that are dissolved often are unstable. 
# > cf$bootbrd
# [1]  1 19 15 12  5  8


#   Plot the dendrogram.
plot(pfit, labels=protein$Country)   




# Building linear discriminant ananlysis for segments

library(MASS) # import library for LDA
library(caret)


train.lda <- train %>% dplyr::select(dplyr::one_of(vars)) %>%
                  mutate(cluster = factor(pam_fit$clustering))

train.lda2 <- train.lda
train.lda2$constant <- 1
scatterPlot(train.lda)

model <- lda(cluster ~ . , data = train.lda)

# create k-Fold cross-validation for LDA

folds <- 5

idx_list <- createFolds(train.lda$cluster, k = 4)

accuracy_list <- c()
for (i in 1:folds) {
  oos_idx <- idx_list[[i]]
  temp_train <- train.lda[-oos_idx, ]
  temp_test <- train.lda[oos_idx, ]
  model <- lda(cluster ~ . , data = temp_train)
  pred <- predict(model, temp_test)$class
  accuracy_list[i] <- mean(as.numeric(pred) == as.numeric(temp_test$cluster))

}

cat('The average of accuracy rate is:', mean(accuracy_list))



model <- lda(cluster ~ ., data = train.lda)

model_coef <- coef(model) # final product.

ntrain <- nrow(train.lda)

singlecov = lapply(1:4, function(x) {
  w <- (sum(train.lda$cluster == x) - 1)/(nrow(train.lda) - 4)
  covar <- w * cov(train.lda[train.lda$cluster == x, vars])
  return(covar)
})

singlecov = Reduce('+', singlecov)

