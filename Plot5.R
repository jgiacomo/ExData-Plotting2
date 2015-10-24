# Script for generating the fifth plot of the assignment. This plot will show
# the total PM2.5 emissions in Baltimore Maryland from motor vehicle sources
# between 1999 and 2008.

# Check if the data frame 'fnei' exists into which I have stored the data. If
# not run the script which will get the data and place it into this data frame.
if(!exists("fnei")){
    source("getFNEI_dataset.R")
}

# Use the dplyr package to filter to just the fips code for Baltimore and then
# summarize the total emissions for each reported year.
library(dplyr)

# First filter to just motor vehicle emissions.
MVsources <- grep('Mobile - On-Road', unique(fnei$EI.Sector), value = TRUE)
motorVeh <- fnei %>% filter(EI.Sector %in% MVsources)

# Next filter to the Baltimore area and group by year.
Baltimore <- motorVeh %>% filter(fips=="24510") %>% group_by(year) %>%
    summarize(totalEmis = sum(Emissions))

# Create a png of a barplot of the total emissions for each reported year.
png(filename="Plot5.png", width=500, height=480, units="px")
par(mar=c(6,5,4,2))  # increase bottom and left margins.
barplot(Baltimore$totalEmis, names.arg=Baltimore$year,
        ylab="PM2.5 Emissions [tons]", xlab="Year")
title(main="Motor Vehicle PM2.5 Emissions for Baltimore City, Maryland",
      sub="Source: National Emissions Inventory, U.S. EPA",
      cex.sub=0.8)
dev.off()
