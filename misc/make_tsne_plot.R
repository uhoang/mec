make_tsne_plot <- function(tsne_obj, cluster) { #, output = FALSE, filepath = 'viz/tsne_cluster.png'
  tsne_data <- as.data.frame(tsne_obj$Y)
  names(tsne_data) <- c('X', 'Y')
  tsne_data$Group <- factor(paste0('Cluster', cluster))
  p <- ggplot(aes(x = X, y = Y), data = tsne_data) + 
  geom_point(aes(color = Group)) +
  my_theme()
  return(p)
  # if (output) ggsave(filename = filepath)
}