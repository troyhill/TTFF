
#' @title getDateOffser
#'
#' @description Identify the number of days needed to convert between a week starting on "Monday" and the desired start day. 
#'
#' @param dataset input dataframe
#' @param dateColumn name of column with datestamp (Date or POSIX data type)
#' @param day character element specifying the first day of each week (default = "Friday", purely to match SFWMD's arbitrary choice)
#'
#' @return a vector of values
#' 
#' @examples 
#'   dateDat        <- data.frame(date = seq.Date(from = Sys.Date() - 100, to = Sys.Date(), by = 1))
#'   dateDat$dow    <- weekdays(dateDat$date)
#'   dateDat$week.R <- format(as.Date(dateDat$date), "%Y-%W")
#'   head(dateDat, 10)
#'   
#'   dateOffset        <- getDateOffset(dateDat, day = "Friday")
#'   dateDat$week.new  <- format(as.Date(dateDat$date) - dateOffset, "%Y-%W")
#'   head(dateDat, 10)
#'   
#' 
#' @export
#'


  # aggregate data to weekly values -----------------------------------------
  # SFWMD "week" ends on Fridays (rownames in weekly dataset are Fridays)
  # My "week" ends on Sundays (rownames in weekly dataset are Sundays)
  
  # outFlow$week <- format(as.Date(outFlow$date), "%Y-%W")
  # outFlow$dow  <- weekdays(as.Date(outFlow$date))
  # 
  # endOfWeek <- tail(outFlow$dow[outFlow$week %in% unique(outFlow$week)[2]], 1) # fragile code - will return inaccurate data if 2nd week is incomplete. Could be improved by taking tail of each week and finding most common value, e.g., https://stackoverflow.com/questions/17374651/finding-the-most-common-elements-in-a-vector-in-r
  # dateOffset <-  min(which(outFlow$dow == firstDayOfWeek)) - min(which(outFlow$dow == endOfWeek))
  
  getDateOffset <- function(dataset, dateColumn = "date", day = "Friday") {
    dataset$week <- format(as.Date(dataset[, dateColumn]), "%Y-%W")
    dataset$dow  <- weekdays(as.Date(dataset[, dateColumn]))
    ### fragile code - will return inaccurate data if 2nd week is incomplete. Could be improved by taking tail of each week and finding most common value, e.g., https://stackoverflow.com/questions/17374651/finding-the-most-common-elements-in-a-vector-in-r
    startOfWeek  <- head(dataset$dow[dataset$week %in% unique(dataset$week)[2]], 1) 
    
    ###                    first desired start day      -    first observed start day
    returnDat    <-  abs(min(which(dataset$dow == day)) - min(which(dataset$dow == startOfWeek))) - 0
    invisible(returnDat) 
  }
