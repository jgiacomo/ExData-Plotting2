# Objective:
# Read in the Fine National Emissions Inventory data set from the
# cloudfront repository (as made available through the Coursera
# course). This data set is a zip file which contains two R data files,
# summarySCC_PM25.rds and Source_Classification_Code.rds. The first contains the
# emissions data and the second contains the mapping from the SCC string code in
# the emissions file to the actual name of the source.

# If the data file isn't already preseent, download and unzip the data file and
# store as a data frame.
if(!file.exists("summarySCC_PM25.rds")){
    fileURL <- paste("https://d396qusza40orc.cloudfront.net/exdata",
                     "%2Fdata%2FNEI_data.zip",
                     sep = "")
    download.file(fileURL, "FNEI.zip", method="auto", mode="wb")
    unzip("FNEI.zip")
    file.remove("FNEI.zip")  # clean up
    rm(fileURL)  # clean up
}

# Read the R data objects into memory from the files.
if(file.exists("summarySCC_PM25.rds")){
    emissions <- readRDS("summarySCC_PM25.rds")
} else {
    print("File 'summarySCC_PM25' does not exist in this directory.")
}

if(file.exists("Source_Classification_Code.rds")){
    sourceClass <- readRDS("Source_Classification_Code.rds")
} else {
    print("File 'Source_Classification_Code.rds' does not exist in this directory")
}

# Join the source class data with the emissions data
library(dplyr)
sourceClass$SCC <- as.character(sourceClass$SCC)
fnei <- left_join(x=emissions, y=sourceClass, by="SCC")
rm(emissions, sourceClass)  # clean up

