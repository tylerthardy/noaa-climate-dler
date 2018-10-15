library(ncdf4)
#devtools::install_github("tidyverse/googlesheets4") #Requires R >=3.5
library(googlesheets4)
library(rgdal)

source("getClimAndTemp.R")


# Load Studies Metadata ---------------------------------------------------
# Load data from Google Sheets
sheetData = read_sheet("1JQoQQ7S82vA7Ats0CkawLgxo3wzeUNC1kw8LPf2Rg6A") %>% data.frame()
# Clean up lat/lon
sheetData$lat = sheetData$lat %>% gsub("°", "", .) %>% as.numeric()
sheetData$lon = sheetData$lon %>% gsub("°", "", .) %>% as.numeric()


# Download Temp/Precip Data -----------------------------------------------
# Download NetCDF for years in metadata
grabYearsFTP(precipFTP, sheetData$year)

# Load NetCDF
# 32-bit R is needed here. RStudio: Go to Tools > Global Options > General, and change "R Version" at top
ncin = nc_open("X:/DATA/precip.1979.nc")

x = ncvar_get(ncin, "lon")
y = ncvar_get(ncin, "lat")
time = ncvar_get(ncin,"time")
precipArray = ncvar_get(ncin, "precip")


#grabYearsFTP(tempFTP, sheetData$year)