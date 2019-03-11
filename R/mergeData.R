
#' @title Merge COP data
#'
#' @description Merges and processes daily rainfall, PET, stage, and flow data into a single dataset aggregated to weekly time steps
#'
#' @param rainfall file address of a tab-delimited .txt file containing daily rainfall data
#' @param PET file address of a tab-delimited .txt file containing daily PET data
#' @param stage file address of a tab-delimited .txt file containing daily stage data
#' @param flow file address of a tab-delimited .txt file containing daily flow data
#'
#' @return a dataframe with all input variables
#' 
#' @importFrom  xts apply.weekly
#' @importFrom  xts as.xts
#' @importFrom  utils read.delim
#' 
#' @export
#'

mergeData <- function(rainfall, PET, stage, flow) {
  a <- list.files("/home/thill/RDATA/git-repos/COPmod/inst/extdata", pattern = "\\.txt$", full.names = TRUE)
  
  rain           <- utils::read.delim(rainfall, skip = 1, stringsAsFactors = FALSE)
  names(rain)[1] <- "date"
  rain           <- rain[, c(nchar(names(rain)) < 20 )]
  rain$date      <- as.POSIXct(rain$date, format = "%m/%d/%Y")
  
  pet           <- utils::read.delim(PET, skip = 1, stringsAsFactors = FALSE)
  names(pet)[1] <- "date"
  pet$date      <- as.POSIXct(pet$date, format = "%m/%d/%Y")
  
  outStage           <- utils::read.delim(stage, skip = 4, stringsAsFactors = FALSE)
  outStage_names     <- utils::read.delim(stage, skip = 1)
  names(outStage)    <- names(outStage_names)
  names(outStage)[1] <- "date"
  outStage$date      <- as.POSIXct(outStage$date, format = "%m/%d/%Y")
  
  
  outFlow           <- utils::read.delim(flow, skip = 6, stringsAsFactors = FALSE)
  outFlow_names     <- utils::read.delim(flow, skip = 1)
  names(outFlow)    <- names(outFlow_names)
  names(outFlow)[2] <- "date"
  outFlow$date      <- as.POSIXct(outFlow$date, format = "%d%b%Y")
  outFlow           <- outFlow[, grep(x = names(outFlow), pattern = "^[A-Z]$", invert = TRUE)] # remove row count column named "B"
  outFlow$sumFlow   <- rowSums(outFlow[, -1], na.rm = TRUE) 
  
  
  # aggregate data to weekly values -----------------------------------------
  # rolling 7-day window? or, weekly intervals?
  rain2      <- xts::as.xts(rain[, -c(1)], order.by = as.Date(rain$date, format = "%Y-%m-%d"))
  rain2.wkly <- xts::apply.weekly(rain2, colSums)
  
  pet2      <- xts::as.xts(pet[, -c(1)], order.by = as.Date(pet$date, format = "%Y-%m-%d"))
  pet2.wkly <- xts::apply.weekly(pet2, colSums) # rate or depth? not sure if this should be sum or mean
  
  outStage2      <- xts::as.xts(outStage[, -c(1)], order.by = as.Date(outStage$date, format = "%Y-%m-%d"))
  outStage2.wkly <- xts::apply.weekly(outStage2, colMeans)
  
  outFlow2              <- xts::as.xts(outFlow[, -c(1)], order.by = as.Date(outFlow$date, format = "%Y-%m-%d"))
  outFlow2.wkly         <- xts::apply.weekly(outFlow2, colSums)
  outFlow2.wkly$sumFlow <- rowSums(outFlow2.wkly[, 2:6])
  
  
  ### create lagged flow variables (lagged by one day)
  outFlow2_lag        <- rbind(NA, data.frame(outFlow2.wkly[-nrow(outFlow2.wkly), -c(1) ])) # lagged by 1
  names(outFlow2_lag) <- paste0(names(outFlow2_lag), ".lag")
  dates               <- row.names(data.frame(outFlow2.wkly))
  outFlow2_lag        <- xts::as.xts(outFlow2_lag, order.by = as.Date(dates, format = "%Y-%m-%d"))
  
  
  
  ### merge all predictors for period of record
  por <- do.call(cbind, list(pet2.wkly, rain2.wkly, outFlow2_lag, outFlow2.wkly[, c("sumFlow")]))
  por <- por[-1, ] # removes row with NAs for lagged variables (necessary for PCA)
  
  invisible(por)
  ### Save merged data for period of record
  # save(list = "por", file = paste0(getwd(), "/data/por.RData"))
}