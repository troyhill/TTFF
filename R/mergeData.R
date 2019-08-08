
#' @title Merge COP data
#'
#' @description Merges and processes daily rainfall, PET, stage, and flow data into a single dataset aggregated to weekly time steps
#'
#' @param rainfall file address of a tab-delimited .txt file containing daily rainfall data
#' @param PET file address of a tab-delimited .txt file containing daily PET data
#' @param stage file address of a tab-delimited .txt file containing daily stage data
#' @param flow file address of a tab-delimited .txt file containing daily flow data
#' @param firstDayOfWeek character element specifying the first day of each week (default = "Friday", purely to match SFWMD's arbitrary choice)
#'
#' @return a dataframe with all input variables
#' 
#' @importFrom  plyr ddply
#' @importFrom  plyr summarise
#' @importFrom  plyr join_all
#' @importFrom  utils head
#' @importFrom  stats complete.cases
#' @importFrom  utils read.delim
#' 
#' @export
#'

mergeData <- function(rainfall, PET, stage, flow, firstDayOfWeek = "Friday") {
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
  outFlow$sumFlow   <- rowSums(outFlow[, !names(outFlow) %in% c("date", "sumFlow")], na.rm = TRUE) # sumFlow = sum of daily flow (cfs) S12A-D, S333
  
  
  # aggregate data to weekly values -----------------------------------------
  # SFWMD "week" ends on Fridays (rownames in weekly dataset are Fridays)
  # My "week" ends on Sundays (rownames in weekly dataset are Sundays)
  
  # outFlow$week <- format(as.Date(outFlow$date), "%Y-%W")
  # outFlow$dow  <- weekdays(as.Date(outFlow$date))
  # 
  # endOfWeek <- tail(outFlow$dow[outFlow$week %in% unique(outFlow$week)[2]], 1) # fragile code - will return inaccurate data if 2nd week is incomplete. Could be improved by taking tail of each week and finding most common value, e.g., https://stackoverflow.com/questions/17374651/finding-the-most-common-elements-in-a-vector-in-r
  # dateOffset <-  min(which(outFlow$dow == firstDayOfWeek)) - min(which(outFlow$dow == endOfWeek))
  
  getDateOffset <- function(dataset, day = firstDayOfWeek) {
    dataset$week <- format(as.Date(dataset$date), "%Y-%W")
    dataset$dow  <- weekdays(as.Date(dataset$date))
    startOfWeek  <- head(dataset$dow[dataset$week %in% unique(dataset$week)[2]], 1) # fragile code - will return inaccurate data if 2nd week is incomplete. Could be improved by taking tail of each week and finding most common value, e.g., https://stackoverflow.com/questions/17374651/finding-the-most-common-elements-in-a-vector-in-r
    returnDat    <-  abs(min(which(dataset$dow == day)) - min(which(dataset$dow == startOfWeek))) - 0
    invisible(returnDat)
  }
  
  dateOffset        <- getDateOffset(outFlow)
  ### now, re-define weeks incorporating offset
  # outFlow$dow2 <- weekdays(as.Date(outFlow$date) + dateOffset) # day-of-week equivalent, where the new "Sunday" is last day of week
  outFlow$week      <- format(as.Date(outFlow$date) + dateOffset, "%Y-%W")
  outFlow.wkly      <- stats::aggregate(outFlow$sumFlow, list(week = outFlow$week), mean)
  ### SFWMD's "weekly flows" are the mean of the sum of daily flows
  ### e.g., the first value in pkg.dat$flow (flow for week of 1-8 Jan 1965) is 1465: the mean of the first seven days of summed structure flows (first 7 values in outFlow$sumFlow)
  names(outFlow.wkly)[names(outFlow.wkly) %in% "x"] <- "sumFlow"
  outFlow.wkly$date <- plyr::ddply(outFlow, ("week"), plyr::summarise, date = head(date, 1))$date # first date in new week

  ### aggregate rain data  
  dateOffset      <- getDateOffset(rain)
  rain$week       <- format(as.Date(rain$date) + dateOffset, "%Y-%W")
  rain2.wkly      <- stats::aggregate(rain[!names(rain) %in% c("date", "week")], list(week = rain$week), sum)
  rain2.wkly$date <- plyr::ddply(rain, ("week"), plyr::summarise, date = head(date, 1))$date
  
  # # rolling 7-day window? or, weekly intervals?
  # rain2      <- xts::as.xts(rain[, -c(1)], order.by = as.Date(rain$date, format = "%Y-%m-%d"))
  # rain2.wkly <- xts::apply.weekly(rain2, colSums)
  
  ### aggregate PET data
  dateOffset     <- getDateOffset(pet)
  pet$week       <- format(as.Date(pet$date) + dateOffset, "%Y-%W")
  pet2.wkly      <- stats::aggregate(pet[!names(pet) %in% c("date", "week")], list(week = pet$week), sum)
  pet2.wkly$date <- plyr::ddply(pet, ("week"), plyr::summarise, date = head(date, 1))$date
  
  # pet2      <- xts::as.xts(pet[, -c(1)], order.by = as.Date(pet$date, format = "%Y-%m-%d"))
  # pet2.wkly <- xts::apply.weekly(pet2, colSums) # rate or depth? not sure if this should be sum or mean
  
  ### aggregate stage data
  dateOffset          <- getDateOffset(outStage)
  outStage$week       <- format(as.Date(outStage$date) + dateOffset, "%Y-%W")
  outStage2.wkly      <- stats::aggregate(outStage[!names(outStage) %in% c("date", "week")], list(week = outStage$week), sum)
  outStage2.wkly$date <- plyr::ddply(outStage, ("week"), plyr::summarise, date = head(date, 1))$date

  # outStage2      <- xts::as.xts(outStage[, -c(1)], order.by = as.Date(outStage$date, format = "%Y-%m-%d"))
  # outStage2.wkly <- xts::apply.weekly(outStage2, colMeans)
  
  # outFlow2              <- xts::as.xts(outFlow[, -c(1)], order.by = as.Date(outFlow$date, format = "%Y-%m-%d"))
  # outFlow.wkly         <- xts::apply.weekly(outFlow2, colSums)
  # outFlow.wkly$sumFlow <- rowSums(outFlow.wkly[, c("S12A", "S12B", "S12C", "S12D", "S333")]) # daily sums (of 5 structures) summed for each week
  ### SFWMD's "weekly flows" are the mean of the sum of daily flows
  ### e.g., the first value in pkg.dat$flow (flow for week of 8 Jan-14 Jan 1965) is 1465: the mean of the first seven days of summed structure flows (first 7 values in outFlow$sumFlow)
  
  
  ### create lagged flow variables (lagged by one day)
  outFlow2_lag        <- rbind(NA, data.frame(outFlow.wkly[-nrow(outFlow.wkly), -c(1) ])) # lagged by 1
  outFlow2_lag$date   <- outFlow.wkly$date
  names(outFlow2_lag)[names(outFlow2_lag) %in% "sumFlow"] <- paste0(names(outFlow2_lag)[names(outFlow2_lag) %in% "sumFlow"], ".lag")
  # outFlow2_lag        <- outFlow2_lag[-1, ]
  
  
  ### merge all predictors for period of record
  # por <- do.call(cbind, list(pet2.wkly, rain2.wkly, outFlow2_lag, outFlow.wkly[, c("sumFlow")]))
  # por <- plyr::join_all(list(pet2.wkly, rain2.wkly, outFlow2_lag, outFlow.wkly[, c("sumFlow", "date")]), by = "date")
  por <- plyr::join_all(list(outFlow2_lag[, c(2,1)],  # puts date column first
                             subset(pet2.wkly, select=-c(get("week"))), 
                             subset(rain2.wkly, select=-c(get("week"))), 
                             subset(outFlow.wkly, select=-c(get("week")))), 
                             by = "date")
  
  
  por <- por[complete.cases(por), ] # removes row with NAs for lagged variables (necessary for PCA)
  
  invisible(por)
  ### Save merged data for period of record
  # save(list = "por", file = paste0(getwd(), "/data/por.RData"))
}
