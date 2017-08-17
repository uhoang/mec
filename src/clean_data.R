set.seed(1680) # for reproducibility
library(mice)
library(dplyr)
library(cluster) # for gower similarity and pam
library(Rtsne) # t-SNE plot
library(ggplot2) # for visualization


#### Clean data --------------------------------


#### one-hot encoding the conditions and preventions


#### Calculating distance ------------------------

# 8 health conditions (Presence/Absence) and 8 health
# preventions (Presence/Absence) are first convertd into 
# 16 binary columns and then the Dice coefficient is used

vars <- c(paste0('con', 1:8), paste0('prev', 1:8))
gower_dist <- daisy(train[ , vars], metric = 'gower')

summary(gower_dist)

# sanity check, print out the most similar and dissimilar pair
# in the dataset to see if it makes sense
gower_mat <- as.matrix(gower_dist)

train[which(gower_mat == min(gower_mat[gower_mat != min(gower_mat)]), arr.ind = TRUE)[1, ], ]
train[which(gower_mat == max(gower_mat[gower_mat != max(gower_mat)]), arr.ind = TRUE)[1, ], ]

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
pam_fit <- pam(gower_dist, diss = TRUE, k = 7)


pam_results <- train %>% dplyr::select(one_of(vars)) %>%
                         mutate(cluster = pam_fit$clustering) %>% 
                         group_by(cluster) %>%
                         do(the_summary = summary(.))

# Via visualization 

tsne_obj <- Rtsne(gower_dist, is_distance = TRUE)
tsne_data <- tsne_obj$Y %>%                          