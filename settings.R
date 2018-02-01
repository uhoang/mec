data_path <- 'data/'
.packages <- c('dplyr', 'cluster', 'Rtsne', 'ggplot2', 'dplyr', 'tidyr', 'openxlsx', 'ggthemes', 'survey')

# Install CRAN packages (if not already installed)
.inst <- .packages %in% installed.packages()
if(length(.packages[!.inst]) > 0) install.packages(.packages[!.inst])
