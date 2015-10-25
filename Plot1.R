# Script for generating the first plot of the assignment. This plot will show
# that the total PM2.5 emissions went down between 1999 and 2008.

# Check if the data frame 'fnei' exists into which I have stored the data. If
# not run the script which will get the data and place it into this data frame.
if(!exists("fnei")){
    # Read the R data objects into memory from the files.
    emissions <- readRDS("summarySCC_PM25.rds")
    sourceClass <- readRDS("Source_Classification_Code.rds")
    
    # Join the source class data with the emissions data
    sourceClass$SCC <- as.character(sourceClass$SCC)
    fnei <- left_join(x=emissions, y=sourceClass, by="SCC")
    rm(emissions, sourceClass)  # clean up
}

# Use the dplyr package to summarize the total emissions for each reported year.
library(dplyr)

yearlyEmissions <- fnei %>% group_by(year) %>%
    summarize(totalEmis = sum(Emissions))

# Create a png of a barplot of the total emissions for each reported year.
# Note that I am scaling the y axis to make it more readable.
png(filename="Plot1.png", width=480, height=480, units="px")
par(mar=c(6,5,4,2))  # increase bottom and left margins.
barplot(yearlyEmissions$totalEmis / 1e+6, names.arg=yearlyEmissions$year,
        ylab="PM2.5 Emissions [millions of tons]", xlab="Year")
title(main="Total PM2.5 Emissions Across the U.S.",
      sub="Source: National Emissions Inventory, U.S. EPA",
      cex.sub=0.8)
dev.off()
