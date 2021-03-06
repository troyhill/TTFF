% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/pca1.R
\docType{data}
\name{pca1}
\alias{pca1}
\title{Data: principal component analysis model for period of record}
\format{results of a call to FactoMineR::PCA():
\describe{
\item{eig}{eigenvalues for the PCA}
\item{var}{variable names and }
\item{ind}{lagged flow data}
\item{svd}{the response variable: the sum of observed flows across Tamiami Trail}
\item{call}{}
}}
\usage{
pca1
}
\description{
A list with 5 elements.
}
\examples{
summary(pca1)

\dontrun{
### code used to generate object 
colsToUse <- 2:55
pca.dat   <- por

pca1 <- FactoMineR::PCA(pca.dat[, colsToUse],  ncp = 4, scale.unit = TRUE)
# save("pca1", file =  paste0(here(), "/data/pca1.RData"))

}

}
\keyword{PET}
\keyword{flow}
\keyword{rainfall}
\keyword{stage}
