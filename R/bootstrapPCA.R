
#' @title Estimate flow across Tamiami Trail
#'
#' @description Applies principal component analysis to new data to generate predicted flow into Everglades National Park
#'
#' @param data input data (will be subsampled to create training and out-of-sample data)
#' @param probTrain proportion of sample data to include in training dataset
#' @param iter number of iterations
#' @param plot logical; whether relationship between preicted and observed flow be displayed on a plot
#' @param columnsUsed numeric range specifying columns in "data" to be used for PCA
#' 
#' 
#' @return a vector of flow estimates
#' 
#' @importFrom  FactoMineR predict.PCA
#' @importFrom  stats coef
#' @importFrom  stats lm
#' @importFrom  stats predict
#' @importFrom  graphics lines
#' 
#' @export
#'

bootstrapPCA <- function(data, probTrain = 0.8, iter = 1000, plot = TRUE, columnsUsed) {
  PCA.dimensions <- 4 # for now
  
  for (i in 1:iter) {
    ind   <- sample(2, nrow(data), replace = TRUE, prob = c(probTrain, 1 - probTrain))
    train <- data[ind == 1, ]
    test  <- data[ind == 2, ]
    
    # use training dataset for PCA
    pca.train <- FactoMineR::PCA(train[, columnsUsed], ncp = PCA.dimensions, scale.unit = TRUE, graph = FALSE) 
    outDat    <- data.frame(cbind(pca.train$ind$coord, sumFlow = data.frame(data$sumFlow[ind == 1])))
    pca.train.lm <- stats::lm(sumFlow ~ Dim.1 + Dim.2 + Dim.3 + Dim.4, data = outDat)
    
    # predict PCs for test dataset 
    test$predFlow <- estimateFlow(PCA_output = pca.train, periodOfRecord = train, newData = test)
    
    summary(lm1 <- stats::lm(sumFlow ~ I(sqrt(predFlow)), data = test[test$sumFlow > 0, ]))
    
    if (plot == TRUE) {
      plot(sumFlow ~ predFlow, data = test[test$sumFlow > 0, ], ylab = "observed flow", xlab = "predicted flow", cex = 0.5, pch = 19)
      curve.dat <- data.frame(predFlow = test[test$sumFlow > 0, "predFlow"], sumFlow = stats::predict(object = lm1))
      curve.dat <- curve.dat[order(curve.dat$predFlow),]
      lines(curve.dat, col=4, lty = 2)  
    }
    
    summaryDF.temp <- data.frame(intercept = as.numeric(lm1$coefficients[1]), slope = as.numeric(lm1$coefficients[2]), 
                                 rsq = summary(lm1)$r.squared, PCA.variance = pca.train$eig[PCA.dimensions, 3])
    if (i == 1) {
      summaryDF <- summaryDF.temp
    } else {
      summaryDF <- rbind(summaryDF, summaryDF.temp)
    }
  }
  invisible(summaryDF)
}