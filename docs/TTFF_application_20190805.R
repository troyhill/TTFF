


### script downloads the previous week's data and runs versions of the TTFF

pkg.list <- c("segmented", "plyr", "FactoMineR", "devtools")
missing.packages <- pkg.list[which(!pkg.list %in% installed.packages())]
if (length(missing.packages) > 0) {
  install.packages(missing.packages, repos='http://cran.us.r-project.org')
}
if (!"SFNRC" %in% installed.packages()) devtools::install_github("troyhill/SFNRC")
if (!"TTFF" %in% installed.packages()) devtools::install_github("troyhill/TTFF")


library(segmented)
library(plyr)
library(FactoMineR)
library(TTFF)
library(SFNRC)









# Prepare data ------------------------------------------------------------


targetDate <- as.Date(as.character(cut(as.Date(Sys.Date()), "week"))) 
# adjustment factor needed to use Friday as the start of the week, per SFWMD training data.


### PET 
### not sure what time scale is used. DataForEver PET is in mm
### adjustments: used station "FMB" instead of "3AS3WX" (which I can't find PET data for). Values are markedly lower than those in the dataset SFWMD provided.
petDat     <- getDBHYDROhydro(dbkey = "US347") # units are inches
petDat.fin <- ifelse(targetDate %in% as.Date(as.character(petDat$date)), 
                     petDat$value[as.Date(as.character(petDat$date)) %in% targetDate],
                     NA)



### precip data
### should be sum of inches for current week. Nexrad data sourced from SFWMD.
# ### modified version uses the sum at station 3AS3WX for the previous week. To add more: https://my.sfwmd.gov/dbhydroplsql/show_dbkey_info.show_dbkeys_matched?v_js_flag=Y&v_category=WEATHER&v_station=%25&v_data_type=RAIN&v_county=DAD&v_dbkey_list_flag=Y&v_order_by=STATION
# pptDat     <- getDBHYDROhydro(dbkey = "LA375")
# pptDat     <- pptDat[as.Date(as.character(pptDat$date)) %in% seq.Date(from = targetDate - 7, to = targetDate - 1, by = "day"), ]
# pptDat.fin <- sum(pptDat$value, na.rm = TRUE) # check that units are inches

url                <- "https://apps.sfwmd.gov/sfwmd/common/images/weather/site_rain/CONSERVAREA3_rain.txt"
pptDat             <- read.table("https://apps.sfwmd.gov/sfwmd/common/images/weather/site_rain/CONSERVAREA3_rain.txt", 
                               sep = ' ',header = FALSE, skip = 12,quote='', comment='', fill = TRUE)
pptDat             <- pptDat[pptDat$V1 %in% "WCA3" , ]
pptDat             <- pptDat[, colSums(is.na(pptDat)) < nrow(pptDat)]
names(pptDat)[1:2] <- c("basin", "date")
pptDat$date        <- as.Date(pptDat$date, format = "%d-%b-%Y")
pptDat$ppt_in      <- rowSums(pptDat[, -c(1:2)], na.rm = TRUE)
pptDat             <- pptDat[, c("basin", "date", "ppt_in")]
pptDat.int         <- pptDat[pptDat$date %in% seq.Date(from = targetDate - 7, to = targetDate - 1, by = "day"), ]
pptDat.fin         <- sum(pptDat.int$ppt_in, na.rm = TRUE)


### WCA stage data
### mean at start of current week
### DBHydro version: Couldn't identify DBKeys
# getDBkey(stn = "3A")
wcaDBKeys  <- c("15943") # in DBHYDRO as "WCA3A average"
wcaDat     <- getDBHYDROhydro(dbkey = wcaDBKeys)
wcaDat.fin <- ifelse(targetDate %in% as.Date(as.character(wcaDat$date)),
                     mean(wcaDat$value[as.Date(as.character(wcaDat$date)) %in% targetDate], na.rm = TRUE),
                     NA)

### NESRS stage data
### stage at start of current week.  units = feet, datum not specified but probably NGVD29
srsDBKey   <- "01218"
srsDat     <- getDBHYDROhydro(dbkey = srsDBKey)
srsDat.fin <- ifelse(targetDate %in% as.Date(as.character(srsDat$date)), 
                     srsDat$value[as.Date(as.character(srsDat$date)) %in% targetDate], 
                     NA)

### S12C/D/S333 flow 
### sum of cfs in previous week (sum of 7 days from each structure)
### Instantaneous DBKeys: 
### Daily means DBKeys: c("03620", "03626", "03632", "03638", "91487")
### alternative DBKeys: S12A: "03620"; S12B: "00610"; S12C: "00621"; S12D: "01310"; S333: "65086"
flowDBKeys  <- c("03620", "03626", "03632", "03638", "91487")
flowDat     <- do.call(rbind, lapply(flowDBKeys, getDBHYDROhydro))
flowDat.int <- flowDat[as.Date(as.character(flowDat$date)) %in% seq.Date(from = targetDate - 7, to = targetDate - 1, by = "day"), ]
### Based on SFWMD's data, sum all structures for each day, then get mean daily value for the week.
### Equivalently, just divide total sum by 7
flowDat.fin <- sum(flowDat.int$value, na.rm = TRUE) / 7

### Zone A regulation schedule at beginning of current week
### why is this not consistent between years?
TTFF.dat       <- read.csv(system.file("extdata", "data_TTFF.csv", package="TTFF")) # their week begins on a Friday
TTFF.dat$date  <- as.POSIXct(TTFF.dat$Date, format = "%m/%d/%Y") 
TTFF.dat$date2 <- substr(TTFF.dat$date, 6, 10)
ZA.dat         <- ddply(TTFF.dat[, !names(TTFF.dat) %in% "date"], .(date2), summarise, ZoneA = mean(Za, na.rm = TRUE))
ZA.fin         <- ZA.dat$ZoneA[ZA.dat$date2 == substr(targetDate, 6, 10)] 


if (any(is.na(c(ZA.fin, petDat.fin, flowDat.fin, srsDat.fin, wcaDat.fin, pptDat.fin)))) {
  stop ("There are not enough new data to update models")
}


# merge all data, create weekly values ----------------------------------------------------------
# SFWMD used Friday as first day of week in their training data. 
# R's sensible default is to use Monday. Not resolving this at the moment.
dateOffset  <- 0 # getDateOffset(dataset = petDat, day = "Friday") # needs more testing

petDat$week <- as.Date(as.character(cut(as.Date(petDat$date) + dateOffset, "week"))) # pet at start of week
pet.wkly    <- ddply(petDat, .(week), summarise, pet = head(value, 1))

pptDat$week <- as.Date(as.character(cut(as.Date(pptDat$date), "week"))) # summed ppt (use previous week's)
ppt.wkly    <- ddply(pptDat, .(week), summarise, ppt = sum(ppt_in, na.rm = TRUE))
### shift by 1 week
ppt.wkly    <- data.frame(week = ppt.wkly$week, prev.ppt = c(NA, ppt.wkly$ppt[-c(nrow(ppt.wkly))]))
                          
wcaDat$week <- as.Date(as.character(cut(as.Date(wcaDat$date), "week"))) # mean stage at start of week
wca.wkly    <- ddply(wcaDat, .(week), summarise, wca = head(value, 1))

srsDat$week <- as.Date(as.character(cut(as.Date(srsDat$date), "week"))) # mean stage at start of week
srs.wkly    <- ddply(srsDat, .(week), summarise, srs = head(value, 1))

flowDat$week <- as.Date(as.character(cut(as.Date(flowDat$date), "week"))) # summed flow (use previous week's)
flow.wkly    <- ddply(flowDat, .(week), summarise, flow = sum(value, na.rm = TRUE) / 7)
### shift flows by one week
flow.wkly    <- data.frame(week = flow.wkly$week, flow = flow.wkly$flow, prev.flow = c(NA, flow.wkly$flow[-c(nrow(flow.wkly))]))
flow.wkly$ZA <- ZA.dat$ZoneA[match(substr(flow.wkly$week, 6, 10), ZA.dat$date2)]


allDat <- join_all(list(pet.wkly, ppt.wkly, wca.wkly, srs.wkly, flow.wkly), by = "week")



# Multiple linear regression (no intercept) -------------------------------

### approximation of Tamiami Trail Flow Formula
pkg.dat        <- read.csv(system.file("extdata", "data_TTFF.csv", package="TTFF"))
names(pkg.dat) <- c("date", "flow", "wca", "srs", "prev.flow", "prev.ppt", "pet", "ZA")
ttff.mod       <- lm(flow ~ wca + srs + prev.flow + prev.ppt + pet + ZA - 1, data = pkg.dat)
# summary(ttff.mod) # R2 = 0.82

allDat$TTFF     <- predict(object = ttff.mod, newdata = allDat, se.fit = TRUE)$fit
allDat$TTFF.err <- predict(object = ttff.mod, newdata = allDat, se.fit = TRUE)$se.fit


# Segmented multiple linear regression ----------------------------------------


### Segmented model
br1 <- 7.00
br2 <- 7.90
lin.mod         <- lm(flow ~ wca + srs, data = pkg.dat)
suppressWarnings(
  segmented.mod <- segmented(lin.mod, seg.Z = ~srs, psi = list(srs = c(br1, br2)))
)
# summary(segmented.mod)

allDat$seg     <- predict(object = segmented.mod, newdata = allDat, se.fit = TRUE)$fit
allDat$seg.err <- predict(object = segmented.mod, newdata = allDat, se.fit = TRUE)$se.fit




# PCA  --------------------------------------------------------------------

### can't recreate training dataset, so here's an approximation

rain.keys <- c(# "06044", "06041", "LX283", "JA344", "K8628", # too many missing values
               "06040", "HB872", "H2004", "H2005")
pet.keys  <- c("US347", "OH516", "OH513")
rh.keys   <- c("LA372", "UP568", "GE351", "16259", "OH514")
hw.keys   <- c("90230", "00604", "AO063", "01307", "AJ013") # all in NAVD88?
### flow: head(flowDat)

rain.pca    <- do.call(rbind, lapply(rain.keys, getDBHYDROhydro))
pet.pca     <- do.call(rbind, lapply(pet.keys, getDBHYDROhydro))
rh.pca      <- do.call(rbind, lapply(rh.keys, getDBHYDROhydro))
hw.pca      <- do.call(rbind, lapply(hw.keys, getDBHYDROhydro))


rain.pca.int         <- reshape(rain.pca[, c("stn", "date", "value")], idvar = "date", timevar = "stn", direction = "wide")
names(rain.pca.int)  <- gsub(x = names(rain.pca.int), pattern = "value", replacement = "rain")
pet.pca.int          <- reshape(pet.pca[, c("stn", "date", "value")], idvar = "date", timevar = "stn", direction = "wide")
names(pet.pca.int)   <- gsub(x = names(pet.pca.int), pattern = "value", replacement = "pet")
hw.pca.int           <- reshape(hw.pca[, c("stn", "date", "value")], idvar = "date", timevar = "stn", direction = "wide")
names(hw.pca.int)    <- gsub(x = names(hw.pca.int), pattern = "value", replacement = "stg")
flow.pca.int         <- reshape(flowDat[, c("stn", "date", "value")], idvar = "date", timevar = "stn", direction = "wide")
names(flow.pca.int)  <- gsub(x = names(flow.pca.int), pattern = "value", replacement = "flow")
flow.pca.int$sumFlow <- rowSums(flow.pca.int[, -1], na.rm = TRUE)

pca.prep <- join_all(list(rain.pca.int, pet.pca.int, hw.pca.int, flow.pca.int), by = "date")

pca.prep$week <- as.Date(as.character(cut(as.Date(pca.prep$date), "week")))
# week starts on Monday
# use sum for rain, PET, flow variables
# use mean for stage variables
wkly.sum  <- plyr::ddply(pca.prep[, grep(x = names(pca.prep), pattern = "rain|pet|week")], .(week), numcolwise(sum, na.rm = TRUE))
wkly.mean <- plyr::ddply(pca.prep[, grep(x = names(pca.prep), pattern = "stg|flow|Flow|week")], .(week), numcolwise(mean, na.rm = TRUE))
wkly.mean$flow.lag <- c(NA, wkly.mean$sumFlow[-nrow(wkly.mean)])

pca.wkly <- join_all(list(wkly.mean, wkly.sum), by = "week")

### separate past year's data
pca.modern <- pca.wkly[pca.wkly$week >= Sys.Date() - 365, ]
pca.hist   <- pca.wkly[pca.wkly$week < Sys.Date() - 365, ]

### run PCA
suppressWarnings(
  pca1 <- FactoMineR::PCA(pca.hist[, -1],  ncp = 6, scale.unit = TRUE)
)

# head(pca1$eig[, c(2,3)]) # ~81% of the variance in the data is captured in the first five principal components

pca.out  <- data.frame(cbind(pca1$ind$coord, 
                             sumFlow = pca.hist$sumFlow))
pca.lm   <- lm(sumFlow ~ Dim.1 + Dim.2 + Dim.3 + Dim.4 + Dim.5 + Dim.6, data = pca.out)
# summary(pca.lm) # r2 = 0.96
# pca.sqrt <- lm(I((sumFlow)^2) ~ Dim.1 + Dim.2 + Dim.3 + Dim.4, data = pca.out)

pcaPred <- FactoMineR::predict.PCA(pca1, newdata = pca.modern)
testDat <- data.frame(pcaPred$coord, week = pca.modern$week)

testDat$pca     <- predict(object = pca.lm, newdata = testDat, se.fit = TRUE)$fit
testDat$pca.err <- predict(object = pca.lm, newdata = testDat, se.fit = TRUE)$se.fit
testDat         <- join_all(list(testDat, pca.modern[, c("week", "sumFlow")]), by = "week")


summary(lm1 <- stats::lm(sumFlow ~ pca, data = testDat)) # r2 = 0.96
plot(sumFlow ~ pca, data = testDat, pch = 19, cex = 0.6)
abline(lm1, col = "red")



# Create figures for git page ---------------------------------------------
### plot past month of combined flow, show current recommendations from each flow formula

beginDate  <- targetDate - 30*9

png(filename = "/home/thill/RDATA/git-repos/TTFF/docs/figures/TTFFestimates.png", width = 10, height = 4, units = "in", res = 150)
TTFF.color <- "firebrick2"
seg.color  <- "dodgerblue3"
pca.color  <- "darkgreen"
maxVal     <-  1.1 * max(allDat$flow[(allDat$week > beginDate) & (allDat$week < targetDate)])
segVal     <- 0.6*maxVal
TTFFVal    <- 0.85*maxVal
pcaVal     <- 0.35*maxVal
if (tail(allDat$seg, 1) >= tail(allDat$TTFF, 1)) {
  segVal   <- 0.85*maxVal
  TTFFVal  <- 0.6*maxVal
}


par(mar = c(3, 5, 1, 0.5))
plot(flow ~ week, 
     data = allDat[allDat$week < targetDate, ],  # exclude current partial week
     pch = 19, cex = 0.6, las = 1, yaxt = "n",
     xlim = c(beginDate, targetDate + 60), 
     ylim = c(0, maxVal), 
     ylab = "",
     xlab = "", type = "l")
axis(side = 2, at = axTicks(side = 2), labels = axTicks(side = 2) / 1000, las = 1)
mtext(text = "Mean cumulative daily flow \n (1k cfs per day; sum of S12s + S333)", side = 2, line = 2.3)
mtext(text = paste0("Flow estimates for week beginning ", format(as.Date(targetDate), "%d %b %Y")), side = 3)
mtext(text = paste0("Figure generated on ", format(as.Date(Sys.Date()), "%d %b %Y")), 
      side = 1, cex = 0.7, line=2, at = targetDate)
### Add prediction history
points(x = allDat$week, y = allDat$TTFF, col = TTFF.color, lty = 2, type = "p", cex = 0.5, pch = 19)
arrows(allDat$week, (allDat$TTFF - allDat$TTFF.err), 
       allDat$week, (allDat$TTFF + allDat$TTFF.err) , 
       length=0.0, angle=90, code=3, col = TTFF.color)

points(x = allDat$week, y = allDat$seg , col = seg.color, lty = 2, type = "p", cex = 0.5, pch = 19)
arrows(allDat$week, (allDat$seg - allDat$seg.err) , 
       allDat$week, (allDat$seg + allDat$seg.err) , 
       length=0.0, angle=90, code=3, col = seg.color)

points(x = testDat$week, y = testDat$pca , col = pca.color, lty = 2, type = "p", cex = 0.5, pch = 19)
arrows(testDat$week, (testDat$pca - testDat$pca.err) , 
       testDat$week, (testDat$pca + testDat$pca.err) , 
       length=0.0, angle=90, code=3, col = pca.color)

text(x = targetDate, y = segVal, # tail(allDat$seg, 1) , 
     paste("Segmented model:\n", round(tail(allDat$seg, 1)), "\u00b1", round(tail(allDat$seg.err, 1)), "cfs"), pos = 4, col = seg.color)
text(x = targetDate, y = TTFFVal, # tail(allDat$TTFF, 1) , 
     paste("Multiple regression:\n", round(tail(allDat$TTFF, 1)), "\u00b1", round(tail(allDat$TTFF.err, 1)), " cfs"), pos = 4, col = TTFF.color)
text(x = targetDate, y = pcaVal,
     paste("PCA model:\n", round(tail(testDat$pca, 1)), "\u00b1", round(tail(testDat$pca.err, 1)), "cfs"), pos = 4, col = pca.color)

dev.off()

