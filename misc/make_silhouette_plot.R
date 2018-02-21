make_silhouette_plot <- function(data) {
  p <- ggplot(data, aes(x = x, y = y)) + 
  geom_line(size = 0.5) +
  geom_point(size = 1.5) +
  my_theme() +
  theme(axis.title = element_text(size = 9),
        axis.text.x = element_text(size = 7),
        axis.text.y = element_text(size = 7)) + 
  ylab('Silhouette width') +
  xlab('Number of clusters') 
  return(p)
}

