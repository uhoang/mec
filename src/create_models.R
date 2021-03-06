# library(dplyr)
library(cluster) # for gower similarity and pam
library(Rtsne) # t-SNE plot
library(ggplot2) # for visualization
library(ulibs)
library(ggthemes)
# library(openxlsx)
source('src/clean_data.R')

n_vars <- ncol(temp_train)

# Convert all variables to logical to treat them as asymmetric binary variables
temp_train[ , vars] <- sapply(temp_train[ , vars], FUN = function(x) ifelse(x == 1, TRUE, FALSE))

# Specify an asymmetry of binary variables in gower distance
gower_dist <- daisy(temp_train, metric = 'gower', type = list(asymm = 1:n_vars))

saveRDS(gower_dist, file = 'output/gower_dist.rds')

# sanity check, print out the most similar and dissimilar pair
# in the dataset to see if it makes sense
# Choosing a clustering alg

# Calculate silhouette width for many k using PAM
sil_width <- c(NA)
kmean_sil_width <- c(NA)

for (i in 2:10) {
  cat(paste0('\rRun PAM and K-means for ', i, ' clusters'))
  # PAM 
  pam_fit <- pam(gower_dist, diss = TRUE, k = i)
  sil_width[i] <- pam_fit$silinfo$avg.width
  
  # K-means
  kmean_fit <- kmeans(gower_dist, centers = i)
  sil <- silhouette(kmean_fit$cluster, gower_dist)
  kmean_sil_width[i] <- mean(sil[ , 'sil_width'])
}


pam_data <- data.frame(x = 2:10, y = sil_width[-1])
kmean_data <- data.frame(x = 2:10, y = kmean_sil_width[-1])

## Plot sihouette width (higher is better)
# py <- ggplot(data, aes(x = x, y = y)) + 
# geom_line(size = 0.5) +
# geom_point(size = 1.5) +
# my_theme() +
# theme(axis.title = element_text(size = 9),
#       axis.text.x = element_text(size = 7),
#       axis.text.y = element_text(size = 7)) + 
# ylab('Silhouette width') +
# xlab('Number of clusters') 

source('misc/make_silhouette_plot.R')
px <- make_silhouette_plot(pam_data)
py <- make_silhouette_plot(kmean_data)
ggarrange(px, py, labels = c('PAM', 'K-Means'), ncol = 2, nrow = 1)

ggsave(filename = 'viz/silhouette_width.png', width = 8, height = 4)

# ggsave(filename = 'viz/silhouette_width_to_select_k.png', width = 5.5, height = 5.5)
# ggsave(filename = 'viz/pam_silhouette_width_vs_num_clusters.png', width = 5.5, height = 3.5)
#ggsave(filename = 'viz/kmean_silhouette_width_vs_num_clusters.png', width = 5.5, height = 3.5)


# Fit data using PAM on number of clusters with the highest sihoutte width
pam_fit <- pam(gower_dist, diss = TRUE, k = which.max(sil_width))
pam_clusters <- pam_fit$clustering
kmean_fit <- kmeans(gower_dist, centers = which.max(kmean_sil_width))
kmean_clusters <- kmean_fit$cluster

# Via visualization
# Visualize many variables in a lower dimensional space with 
# t-distributed stochastic neighborhood embedding (t-SNE) technique.
# Allow us to view gower distance in 2D or 3D
source('misc/make_tsne_plot.R')

# Create t-SNE object from the obtained Gower distances
tsne_obj <- Rtsne(gower_dist, is_distance = TRUE)

# # See how well-seperated clusters that PAM detects
tx <- make_tsne_plot(tsne_obj, pam_clusters)

# # See how well-seperated clusters that K-means detects
ty <- make_tsne_plot(tsne_obj, kmean_clusters)

ggarrange(tx, ty, labels = c('PAM', 'K-Means'), ncol = 2, nrow = 1)

ggsave(filename = 'viz/tsne.png', width = 10, height = 5)

cluster[as.numeric(names(pam_clusters))] <- paste0('Cluster', pam_clusters)
train$cluster <- cluster

select_vars <- grep('h_|Q_|age_break|cluster|uuid|date', names(train), value = TRUE, ignore.case = TRUE)
saveRDS(train[ , select_vars], 'output/clustered_data.rds')

# Future work: try divisive hierarchical clustering (HC) with diana [in cluster package]
# or agglomerative HC with agnes [in cluster package]
# references: http://uc-r.github.io/hc_clustering


# Cluster interpretation via descriptive statistics
pam_results <- train %>% dplyr::select(dplyr::one_of(c(vars, 'cluster'))) %>%
                         # mutate(cluster = cluster) %>% 
                         group_by(cluster) %>%
                         do(the_summary = summary(.))
pam_results$the_summary

library(fpc)
# Test stability of clusters using bootstrap for PAM
cf_pam <- clusterboot(gower_dist, B = 100, 
                  bootmethod = c('boot'), #, 'subset', 'noise', 'jitter'
                  clustermethod = claraCBI,
                  k = 10, seed = 12345)

cf_kmean <- clusterboot(gower_dist, B = 100, 
                  bootmethod = c('boot', 'subset'), 
                  clustermethod = kmeansCBI,
                  k = 2, seed = 12345)


print(cf_pam, statistics = c('mean', 'dissolution', 'recovery'))
plot(cf_pam, xlim=c(0,1),breaks=seq(0,1,by=0.05))

sink('output/kmean_stability_assessment.txt')
print(cf_kmean, statistics = c('mean', 'dissolution', 'recovery'))
sink()


# Fit data using PAM on number of clusters with the highest sihoutte width
pam_fit <- pam(gower_dist, diss = TRUE, k = 4)
pam_clusters <- pam_fit$clustering

kmean_fit <- kmeans(gower_dist, centers = 2)
kmean_clusters <- kmean_fit$cluster

make_tsne_plot(tsne_obj, pam_clusters, 
              output = FALSE, 
              filepath = paste0('viz/kmean_tsne_', 2, 'clusters.png'))


make_tsne_plot(tsne_obj, kmean_clusters, 
              output = FALSE, 
              filepath = paste0('viz/kmean_tsne_', 2, 'clusters.png'))


# cluster[as.numeric(names(pam_clusters))] <- paste0('Cluster', pam_clusters)
cluster[as.numeric(names(kmean_clusters))] <- paste0('Cluster', kmean_clusters)
train$cluster <- cluster

# kmean_fit <- kmeans(gower_dist, centers = which.max(kmean_sil_width))
# kmean_clusters <- kmean_fit$cluster

vars <- grep('Q_COND|Q_PREV|Q_AGE', names(train), value = TRUE)

# Cluster interpretation via descriptive statistics
kmean_results <- train %>% dplyr::select(dplyr::one_of(c(vars, 'cluster'))) %>%
                         # mutate(cluster = cluster) %>% 
                         group_by(cluster) %>%
                         do(the_summary = summary(.))

sink('output/summary.txt')
print(kmean_results$the_summary)
sink()


vars <- grep('Q_CON|Q_PREV|Q_STATE|Q_GOAL|Q_AGES|Q_PROV|Q_COMMUNITY|Q_GENDER|Q_PARENT', names(train), value = TRUE)

sink('output/sample_data.txt')
kable(train[1:6, vars[1:53]], caption = 'Sample of dataset')
sink()