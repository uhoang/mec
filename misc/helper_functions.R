weighted.se <- function(x, w, na.rm=FALSE)
#  Computes the variance of a weighted mean following Cochran 1977 definition
{
  if (na.rm) { w <- w[i <- !is.na(x)]; x <- x[i] }
  n = length(w)
  xWbar = weighted.mean(x,w,na.rm=na.rm)
  wbar = mean(w)
  out = n/((n-1)*sum(w)^2)*(sum((w*x-wbar*xWbar)^2)-2*xWbar*sum((w-wbar)*(w*x-wbar*xWbar))+xWbar^2*sum((w-wbar)^2))
  return(sqrt(out))
}


one_hot_encode <- function(x) {
  val <- sort(unique(x))
  m <- matrix(0, length(x), length(val))
  m[cbind(1:length(x), match(x, val))] <- 1
  colnames(m) <- paste0('var', val)
  return(as.data.frame(m))
}


# data <- temp
# formula <- as.formula('var ~ group + h_AGE + h_PROVINCE')
# # data <- temp
# conf.level <- .95
# data <- temp_data

get_sig_pairs <- function(data, formula, conf.level = .95, n_group = 7, group_name = 'cluster') {
  aov.out <- aov(formula, data = data)
  pvalues <- TukeyHSD(aov.out, group_name, conf.level = conf.level)[[group_name]][ , 'p adj']
  pvalues <- pvalues[pvalues < 0.05]
  sign_pairs <- unlist(lapply(1:n_group, function(v) {
    grp <- grep(v, names(pvalues), value = TRUE)
    grp <- gsub(paste0(c('Cluster|-', v), collapse = '|'), '', grp)
    return(paste0(grp, collapse = ','))
  }))
  return(sign_pairs)
}

# get_sig_pairs(temp, formulas)
