#' Data: principal component analysis model for period of record
#'
#' @description A list with 5 elements.
#'
#' @format results of a call to FactoMineR::PCA():
#' \describe{
#' \item{eig}{eigenvalues for the PCA}
#' \item{var}{variable names and }
#' \item{ind}{lagged flow data}
#' \item{svd}{the response variable: the sum of observed flows across Tamiami Trail}
#' \item{call}{}
#'}
#' @docType data
#' @keywords rainfall PET stage flow
#' @name por
#' @examples 
#' summary(pca1)
#' 
#' \dontrun{
#' ### code used to generate object 
#' colsToUse <- 2:55
#' pca.dat   <- por
#' 
#' pca1 <- FactoMineR::PCA(pca.dat[, colsToUse],  ncp = 4, scale.unit = TRUE)
#' # save("pca1", file =  paste0(here(), "/data/pca1.RData"))
#' 
#' }
#' 
"pca1"