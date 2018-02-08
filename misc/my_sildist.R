
dist <- as.matrix(gower_dist)
cluster <- pam_fit$clustering
my_sildist <- function(cluster, dist) {
  # cluster: a vector of classes
  # dist: a matrix or data.frame of distances
  if (!is.matrix(dist) & !is.data.frame(dist)){
    stop('dist needs to be matrix or data.frame')
  } 
  if (is.matrix(dist)) {
    # colnames(dist) <- paste0('X', 1:ncol(dist))
    dist <- as.data.frame(dist)
  }
  names(dist) <- paste0('X', 1:ncol(dist))
  classes <- data.frame(id = names(dist), 
                        cluster_id = cluster,
                        stringsAsFactors = FALSE)
  dist <- data.frame(row_id = names(dist),
                    cluster = cluster,
                    dist, stringsAsFactors = FALSE)


  temp <- tidyr::gather(dist, key = 'obs', value = 'dist', grep('X', names(dist), value = TRUE)) %>%
          dplyr::inner_join(classes, by = c('obs' = 'id')) %>%
          dplyr::filter(row_id != obs) %>% 
          dplyr::group_by(obs, cluster) %>%
          dplyr::summarize(avg = mean(dist),
                          member = unique(cluster_id)) %>%
          dplyr::group_by(obs) %>%
          dplyr::mutate(a_i = avg[cluster == unique(member)], 
                        b_i = min(avg[cluster != unique(member)])) %>% 
          dplyr::summarize(sil_width = unique(b_i - a_i)/max(a_i, b_i))
  return(temp)
}