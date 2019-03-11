
#' @title Estimate flow across Tamiami Trail
#'
#' @description Applies principal component analysis to new data to generate predicted flow into Everglades National Park
#'
#' @param PCA_output output of principal component analysis
#' @param periodOfRecord period of record data used to run PCA
#' @param newData a new dataset with identical variable names as the data used for the PCA. Generate this object with the mergeData() function.
#'
#' @return a vector of flow estimates
#' 
#' @importFrom  FactoMineR predict.PCA
#' @importFrom  stats coef
#' @importFrom  stats lm
#' 
#' @export
#'

estimateFlow <- function(PCA_output, periodOfRecord, newData) {
  
  pca.out <- data.frame(cbind(PCA_output$ind$coord, sumFlow = data.frame(periodOfRecord$sumFlow)))
  pca.lm  <- stats::lm(sumFlow ~ Dim.1 + Dim.2 + Dim.3 + Dim.4, data = pca.out)
  
  ### predict PCs for test dataset 
  pcaPred          <- FactoMineR::predict.PCA(PCA_output, newdata = newData)
  
  # temp             <- data.frame(pcaPred$coord, date = row.names(pcaPred$coord))
  # tempData         <- data.frame(periodOfRecord, date = row.names(data.frame(periodOfRecord)))
  # testDat          <- plyr::join_all(list(temp, tempData), by = "date")
  
  ### predict flow from principal component values
  testDat            <- data.frame(pcaPred$coord, date = row.names(pcaPred$coord))
  
  predFlow <- stats::coef(pca.lm)[1] + stats::coef(pca.lm)[2] * testDat$Dim.1 + 
    stats::coef(pca.lm)[3] * testDat$Dim.2 + stats::coef(pca.lm)[4] * testDat$Dim.3 +  stats::coef(pca.lm)[5] * testDat$Dim.4
  
  invisible(predFlow)
}