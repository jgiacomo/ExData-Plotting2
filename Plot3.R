# Script for generating the third plot of the assignment. This plot will show
# the total PM2.5 emissions in Baltimore Maryland for each source type between
# 1999 and 2008.

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

# Use the dplyr package to filter to just the fips code for Baltimore and then
# summarize the total emissions for each source type and reported year.
library(dplyr)

Baltimore <- fnei %>% filter(fips=="24510") %>% group_by(year, type) %>%
    summarize(totalEmis = sum(Emissions))

# Create a png of a ggplot2 line plot of the total emissions for each source
# type for reported year.
library(ggplot2)

p1 <- ggplot(Baltimore, aes(x=year, y=totalEmis, color=type))
p1 <- p1 + geom_line() + geom_point(size=3)
p1 <- p1 + scale_x_continuous(breaks=c(1999,2002,2005,2008))
p1 <- p1 + labs(x="Year", y="Yearly PM2.5 Emission [tons]",
                color="Source Type")
p1 <- p1 + ggtitle(expression(
    atop("Total PM2.5 Emission in Baltimore by Source Type",
         atop(italic("Source: National Emissions Inventory, U.S. EPA"),
              ""))))
png(filename="Plot3.png", width=550, height=480, units="px")
print(p1)
dev.off()
