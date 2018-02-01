library(dplyr)
library(cluster) # for gower similarity and pam
library(Rtsne) # t-SNE plot
library(ggplot2) # for visualization
# library(openxlsx)
source('src/clean_data.R')

gower_dist <- daisy(temp_train, metric = 'gower')

# gower_mat <- as.matrix(gower_dist)
# save(gower_mat, file = 'output/gower_mat.RData')

# temp_train[, vars[-1]] <- sapply(temp_train[ , vars[-1]], function(x) ifelse(x == 1, TRUE, FALSE))
# temp_train[, vars] <- sapply(temp_train[ , vars], function(x) ifelse(x == 1, TRUE, FALSE))
# gower_dist <- daisy(temp_train[ , vars], metric = 'gower', type = list(asymm =  1:nvars))
# gower_dist <- daisy(temp_train[, vars], metric = 'gower', type = list(asymm = 2:nvars))

# sanity check, print out the most similar and dissimilar pair
# in the dataset to see if it makes sense
# Choosing a clustering alg

# Calculate silhouette width for many k using PAM
# sil_width <- c(NA)

# for (i in 2:10) {
#   pam_fit <- pam(gower_dist, diss = TRUE, k = i)
#   sil_width[i] <- pam_fit$silinfo$avg.width
# }

# data <- data.frame(x = 2:10, y = sil_width[-1])

# Plot sihouette width (higher is better)
# ggplot(data, aes(x = x, y = y)) + 
# geom_line(size = 0.8) +
# geom_point(size = 2.5) +
# my_theme() +
# theme(axis.title = element_text(size = 13.5)) + 
# ylab('Silhouette width') +
# xlab('Number of clusters') 

# ggsave(filename = 'viz/silhouette_width_to_select_k.png', width = 5.5, height = 5.5)

# Fit data using PAM on 6 clusters
pam_fit <- pam(gower_dist, diss = TRUE, k = 6)
cluster[as.numeric(names(pam_fit$clustering))] <- paste0('Cluster', pam_fit$clustering)
train$cluster <- cluster

select_vars <- grep('h_|Q_|age_break|cluster|uuid|date', names(train), value = TRUE, ignore.case = TRUE)

saveRDS(train[ , select_vars], 'output/deidentified_train.rds')

saveRDS(train, 'output/train.rds')

# Cluster interpretation via descriptive statistics
# pam_results <- train %>% dplyr::select(dplyr::one_of(c(vars, 'cluster'))) %>%
#                          # mutate(cluster = cluster) %>% 
#                          group_by(cluster) %>%
#                          do(the_summary = summary(.))
# pam_results$the_summary

# Via visualization 
# plot gower distance for 6 clusters in 2D
# gower_dist <- daisy(temp_train[ , vars], metric = 'gower')
# tsne_obj <- Rtsne(gower_dist, is_distance = TRUE)

# tsne_data <- tsne_obj$Y %>% data.frame() %>% 
#             setNames(c('X', 'Y')) %>% 
#             mutate(tsncluster = factor(paste0('Cluster', pam_fit$clustering)))
#             # mutate(tsncluster = factor(train$cluster))

# names(tsne_data)[3] <- 'Group'
# ggplot(aes(x = X, y = Y), data = tsne_data) + 
# geom_point(aes(color = Group)) +
# my_theme()

# ggsave(filename = 'viz/tsne_cluster_6.png')

# # plot gower distance for 7 cluster in 2D
# gower_dist2 <- daisy(train[ , vars], metric = 'gower')
# tsne_obj <- Rtsne(gower_dist2, is_distance = TRUE)

# tsne_data <- tsne_obj$Y %>% data.frame() %>% 
#             setNames(c('X', 'Y')) %>% 
#             mutate(tsncluster = factor(paste0('Cluster', pam_fit$clustering)))
#             # mutate(tsncluster = factor(train$cluster))

# names(tsne_data)[3] <- 'Group'
# ggplot(aes(x = X, y = Y), data = tsne_data) + 
# geom_point(aes(color = Group)) +
# my_theme()

# ggsave(filename = 'viz/tsne_cluster_7.png')


# Test stability of clusters using bootstrap
# clusterboot(gower_dist, B = 10)
# cf <- clusterboot(gower_dist, B = 100, 
#                   bootmethod = c('boot'), 
#                   clustermethod = claraCBI,
#                   k = 6, seed = 12345)


# > cf$bootmean
# [1] 0.8642140 0.7106713 0.6741667 0.7403177 0.7828143 0.7764324
# the observations in cluster 1 have highly similar health condition and prevention,
# distinct from those of the other cluster

# we can also say that the individuals in cluster 2-6 represent distinct health behaviours/patterns
# but there isn't high certainty about which points should be clustered together.

# number of times each cluster was dissolved. Clusters that are dissolved often are unstable. 
# > cf$bootbrd
# [1]  1 19 15 12  5  8


#   Do the clustering. 
# pfit <- hclust(gower_mat, method="ward")   

#   Plot the dendrogram.
# plot(pfit, labels=protein$Country)   




# Building linear discriminant ananlysis for segments

# library(caret)
# library(MASS) # import library for LDA

# train.lda <- train %>% dplyr::select(dplyr::one_of(vars)) %>%
#                   mutate(cluster = factor(pam_fit$clustering))

# train.lda2 <- train.lda
# train.lda2$constant <- 1
# scatterPlot(train.lda)

# model <- lda(cluster ~ . , data = train.lda)

# # create k-Fold cross-validation for LDA

# folds <- 5

# idx_list <- createFolds(train.lda$cluster, k = 4)

# accuracy_list <- c()
# for (i in 1:folds) {
#   oos_idx <- idx_list[[i]]
#   temp_train <- train.lda[-oos_idx, ]
#   temp_test <- train.lda[oos_idx, ]
#   model <- lda(cluster ~ . , data = temp_train)
#   pred <- predict(model, temp_test)$class
#   accuracy_list[i] <- mean(as.numeric(pred) == as.numeric(temp_test$cluster))

# }

# cat('The average of accuracy rate is:', mean(accuracy_list))



# model <- lda(cluster ~ ., data = train.lda)

# model_coef <- coef(model) # final product.

# ntrain <- nrow(train.lda)

# singlecov = lapply(1:4, function(x) {
#   w <- (sum(train.lda$cluster == x) - 1)/(nrow(train.lda) - 4)
#   covar <- w * cov(train.lda[train.lda$cluster == x, vars])
#   return(covar)
# })

# singlecov = Reduce('+', singlecov)

