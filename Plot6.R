# Script for generating the sixth plot of the assignment. This plot will show
# PM2.5 emissions from motor vehicles in Baltimore Maryland and Los Angeles
# California between 1999 and 2008.

library(dplyr)
library(ggplot2)

# Check if the data frame 'fnei' exists into which I have stored the data. If
# not get the data from the R data files and place it into this data frame.
if(!exists("fnei")){
    # Read the R data objects into memory from the files.
    emissions <- readRDS("summarySCC_PM25.rds")
    sourceClass <- readRDS("Source_Classification_Code.rds")
    
    # Join the source class data with the emissions data
    sourceClass$SCC <- as.character(sourceClass$SCC)
    fnei <- left_join(x=emissions, y=sourceClass, by="SCC")
    rm(emissions, sourceClass)  # clean up
}

# First filter to just motor vehicle emissions.
MVsources <- grep('Mobile - On-Road', unique(fnei$EI.Sector), value = TRUE)
motorVeh <- fnei %>% filter(EI.Sector %in% MVsources)

# Next filter to the Baltimore and Los Angeles areas and group by year.
plotData <- motorVeh %>% filter(fips %in% c("24510","06037")) %>%
    group_by(fips, year) %>% summarize(totalEmis = sum(Emissions))

# Create a png of a ggplot2 line plot of the motor vehicle emissions for each
# region.
library(ggplot2)

p1 <- ggplot(plotData, aes(x=year, y=totalEmis, color=fips))
p1 <- p1 + geom_line() + geom_point(size=3)
p1 <- p1 + scale_x_continuous(breaks=c(1999,2002,2005,2008))
p1 <- p1 + labs(x="Year", y="Yearly PM2.5 Emission [tons]")
p1 <- p1 + scale_color_discrete(name="Region",
                               breaks=c("06037", "24510"),
                               labels=c("Los Angeles, CA",
                                        "Baltimore City, MD"))
p1 <- p1 + ggtitle(expression(
    atop("Motor Vehicle PM2.5 Emissions",
         atop(italic("Source: National Emissions Inventory, U.S. EPA"),
              ""))))
png(filename="Plot6.png", width=550, height=480, units="px")
print(p1)
dev.off()
