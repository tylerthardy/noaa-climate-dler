#library(devtools)
#devtools::install_github("tidyverse/googlesheets4") #Requires R >=3.5; all other libraries shouldn't be loaded first
library(ncdf4)
library(googlesheets4)
library(rgdal)

source("getClimAndTemp.R")


# Load Studies Metadata ---------------------------------------------------
# Load data from Google Sheets
sheetData = read_sheet("1Hv_AhMzyz9nKh0QD_FlE6tK11NWgdoSQALH6pxOzBZU") %>% data.frame()
# Clean up lat/lon
sheetData$Spot.Lat = sheetData$Spot.Lat %>% gsub("°", "", .) %>% as.numeric()
sheetData$Spot.Lon = sheetData$Spot.Lon %>% gsub("°", "", .) %>% as.numeric()


# Download Temp/Precip Data -----------------------------------------------
# Download NetCDF for years in metadata
grabYearsFTP(precipFTP, unique(sheetData$year))

# Load NetCDF
# 32-bit R is needed here. RStudio: Go to Tools > Global Options > General, and change "R Version" at top
ncin = nc_open("C:/DATA/NOAA-CPC/precip.2002.nc")

x = ncvar_get(ncin, "lon")
y = ncvar_get(ncin, "lat")
time = ncvar_get(ncin,"time")
dayTime = as.POSIXct(time * 3600,origin='1900-01-01 00:00')
precipArray = ncvar_get(ncin, "precip")

for (i in 1:nrow(sheetData)) {
  row = sheetData[i,]
  year = row$year
  months = unlist(strsplit(row$time, " "))
  if ("Dec" %in% months & "Jan" %in% months)
  {
    warning(sprintf("Skipping study (%s) overlapping year found; no function implemented yet", i))
    next()
  }
  
  ncFileName = sprintf("C:/DATA/NOAA-CPC/precip.%s.nc", year)
  ncData = nc_open(ncFileName)

  lon = ncvar_get(ncin, "lon")
  lowerLon = lon[findInterval(row$Spot.Lon, lon)+1]
  upperLon = lon[findInterval(row$Spot.Lon, lon)]
  
  lat = ncvar_get(ncin, "lat")
  upperLat = lat[length(lat)-findInterval(row$Spot.Lat, sort(lat))]
  lowerLat = lat[length(lat)-findInterval(row$Spot.Lat, sort(lat))+1]
  
  time = ncvar_get(ncin, "time")
  dayTime = as.POSIXct(time * 3600, origin='1900-01-01 00:00')
  dfTime = data.frame(time=time,
                 posix=dayTime,
                 month=months(dayTime, abbreviate=T))
  
  which(dfTime$month %in% months)
  
  precipArray = ncvar_get(ncin, "precip")
  plot(raster(ncFileName, band=215), xlab="lon", ylab="lat")
  points(row$Spot.Lon, row$Spot.Lat, pch=20)
  plot(raster(ncFileName, band=215), xlim=c(upperLon, lowerLon), ylim=c(lowerLat, upperLat), xlab="lon", ylab="lat")
  points(row$Spot.Lon, row$Spot.Lat, pch=20)
  plot(raster(ncFileName, band=215), xlim=c(100, 120), ylim=c(20, 60), xlab="lon", ylab="lat")
  points(row$Spot.Lon, row$Spot.Lat, pch=20)
  points(row$Spot.Lon, row$Spot.Lat, pch=20)
}

doTheThing = function(lati, longi, day) {
  latIdx = length(lat)-findInterval(lati, rev(lat))+1
  lonIdx = findInterval(longi, lon)
  
  plot(raster(ncFileName, band=day), xlim=c(longi*0.90, longi*1.1), ylim=c(lati*0.90, lati*1.1), xlab="lon", ylab="lat")
  
  points(longi, lati)
  points(lon[lonIdx], lat[latIdx], pch=".")
  precipArray[lonIdx, latIdx, day]
}

doTheThing(41, 115, 215)
doTheThing(41, 180+115.2, 215)

#grabYearsFTP(tempFTP, sheetData$year)