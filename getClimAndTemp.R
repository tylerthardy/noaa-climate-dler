library(RCurl)

precipFTP = "ftp://ftp.cdc.noaa.gov/Datasets/cpc_global_precip/" #https://www.esrl.noaa.gov/psd/data/gridded/data.cpc.globalprecip.html
tempFTP = "ftp://ftp.cdc.noaa.gov/Datasets/cpc_global_temp/" #https://www.esrl.noaa.gov/psd/data/gridded/data.cpc.globaltemp.html

currentYear = as.numeric(format(Sys.Date(), "%Y"))

downloadDir = "C:/DATA/NOAA-CPC/"

# Download NetCDF Files ---------------------------------------------------
grabAllFilesFTP = function(ftpUrl) {
  # Grab list of files in FTP directory
  dir <- unlist(
    strsplit(
      getURL(ftpUrl,verbose=TRUE,
             ftp.use.epsv=TRUE, 
             dirlistonly = TRUE),
      "\r\n")
  )
  
  # Download all files
  for (file in dir) {
    download.file(url = paste0(ftpUrl, file),
                  destfile = paste0(downloadDir, file),
                  mode = "wb")
  }
}

grabYearsFTP = function(ftpUrl, years) {
  # Grab list of files in FTP directory
  dir <- unlist(
    strsplit(
      getURL(ftpUrl,verbose=TRUE,
             ftp.use.epsv=TRUE, 
             dirlistonly = TRUE),
      "\r\n")
  )
  
  # Grab file years
  # ---
  # Example: precip.1979.nc
  # nchar(dir)-7 + 1 = location of year first char
  # nchar(dir)-7 + 4 = location pre file extension 
  dirYears = substring(dir, nchar(dir)-7 + 1, nchar(dir)-7 + 4)
  
  # Select files which are in year
  dir = dir[dirYears %in% years]
  
  # Download all files
  for (fileName in dir) {
    dlPath = paste0(ftpUrl, fileName)
    destPath = paste0(downloadDir, fileName)
    
    # Download file if the file hasn't been download, or is the current year (may have new data)
    if (!file.exists(destPath) | grepl(currentYear, fileName)) { 
      download.file(url = dlPath,
                    destfile = destPath,
                    mode = "wb")
    }
  }
}

# Usage -------------------------------------------------------------------
# grabAllFilesFTP(precipFTP)
# grabAllFilesFTP(tempFTP)
# 
# grabYearsFTP(precipFTP, c(1980, 1993))
