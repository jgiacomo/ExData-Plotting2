# Script for generating the fourth plot of the assignment. This plot will show
# the total PM2.5 emissions across the U.S. for all coal combustion sources
# between 1999 and 2008.

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

# Use the dplyr package to filter coal sources and summarize total emissions.
library(dplyr)

# Find all the EI.Sector sources which are coal combustion related.
coalSources <- mapply(grep, 'Coal', unique(fnei$EI.Sector), value=TRUE)
coalSources <- as.vector(coalSources)  # change matrix to vector

# Filter emission data by coal sources and sum emissions over each year.
coalEmissions <- fnei %>% filter(EI.Sector %in% coalSources) %>%
    group_by(year) %>%
    summarize(totalEmis = sum(Emissions))

# Create a png of a barplot of the total emissions for each reported year.
# Note that I am scaling the y axis to make it more readable.
png(filename="Plot4.png", width=525, height=480, units="px")
par(mar=c(6,5,4,2))  # increase bottom and left margins.
barplot(coalEmissions$totalEmis / 1e+3, names.arg=coalEmissions$year,
        ylab="PM2.5 Emissions [thousands of tons]", xlab="Year")
title(main="Total U.S. PM2.5 Emissions From Coal Combustion Sources",
      sub="Source: National Emissions Inventory, U.S. EPA",
      cex.sub=0.8)
dev.off()
