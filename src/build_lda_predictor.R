# Building linear discriminant ananlysis for segments

# library(caret)
# library(MASS) # import library for LDA

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

# singlecov = Reduce('+', singlecov)

