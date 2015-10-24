# Script for generating the fourth plot of the assignment. This plot will show
# the total PM2.5 emissions across the U.S. for all coal combustion sources
# between 1999 and 2008.

library(dplyr)
library(mapproj)
library(RColorBrewer)

# Check if the data frame 'fnei' exists into which I have stored the data. If
# not run the script which will get the data and place it into this data frame.
if(!exists("fnei")){
    source("getFNEI_dataset.R")
}

# Find all the EI.Sector sources which are coal combustion related.
EIsector <- fnei %>% select(EI.Sector) %>% unique()
coalSources <- mapply(grep, 'Coal', EIsector, value=TRUE)
coalSources <- as.vector(coalSources)  # change matrix to vector

# Filter emission data by coal sources and years 1999 and 2008.
coalEmissions <- fnei %>%
    filter(EI.Sector %in% coalSources, year %in% c(1999, 2008)) %>%
    select(fips, year, Emissions, EI.Sector)

# Summarize by year over all coal sources.
coalEmissions <- coalEmissions %>% group_by(fips, year) %>%
    summarize(totalEmissions = sum(Emissions))

coalEmissions <- mutate(coalEmissions, fipsState = substr(fips,1,2),
                        fipsNum = as.numeric(fipsState))
coalEmissions <- coalEmissions[complete.cases(coalEmissions),]

yr1999 <- coalEmissions %>% filter(year==1999) %>% select(fips, totalEmissions)
yr1999$fipsCHR <- as.integer(yr1999$fips)
yr1999 <- yr1999[,-1]
names(yr1999) <- c("em1999", "fips")

yr2008 <- coalEmissions %>% filter(year==2008) %>% select(fips, totalEmissions)
yr2008$fipsCHR <- as.integer(yr2008$fips)
yr2008 <- yr2008[,-1]
names(yr2008) <- c("em2008", "fips")

coal <- inner_join(yr1999, yr2008)
coal <- mutate(coal, diff = em2008 - em1999)

# Remove any NA values from the fips column
coalEmissions <- coalEmissions[coalEmissions$fips!="NA",]

# Now for the mapping.
data(county.fips)  # load the county fips data

mapColors <- brewer.pal(9, "RdBu")  # 9 colors from diverging pallete
mapColors[5] <- "#DDDDDD"  # change center color to distinguish from white.
# Define regions in coal$diff to apply the 9 colors.
coal$colorBuckets <- as.numeric(cut(coal$diff,
                                    c(-1e12, -20, -10, -5, -2,
                                      2, 5, 10, 20, 1e12)))
# Match the colors with the counties
colorsmatched <- coal$colorBuckets[match(county.fips$fips, coal$fips)]

png(filename="alternatePlot4.png", width=1000, height=800, units="px")
# Plot the county map with the colors as defined.
map("county",
    col = mapColors[colorsmatched],
    fill = TRUE,
    resolution = 0,
    lty = 0,
    projection = "polyconic")

# Plot the state boundary lines.
map("state",
    col = "black",
    fill = FALSE,
    add = TRUE,
    lty = 1,
    lwd = 0.4,
    projection = "polyconic")

title("Coal Source PM2.5 Emission Differences Between 1999 and 2008 by County")
leg.txt <- c("< -20", "-20 to -10", "-10 to -5", "-5 to -2", "-2 to 2",
             "2 to 5", "5 to 10", "10 to 20", "> 20", "no data")
legend("top", leg.txt, horiz = TRUE, fill = c(mapColors, "#FFFFFF"))

dev.off()
# Create a png of a barplot of the total emissions for each reported year.
# Note that I am scaling the y axis to make it more readable.
# png(filename="Plot4.png", width=525, height=480, units="px")
# par(mar=c(6,5,4,2))  # increase bottom and left margins.
# barplot(coalEmissions$totalEmis / 1e+3, names.arg=coalEmissions$year,
#         ylab="PM2.5 Emissions [thousands of tons]", xlab="Year")
# title(main="Total U.S. PM2.5 Emissions From Coal Combustion Sources",
#       sub="Source: National Emissions Inventory, U.S. EPA",
#       cex.sub=0.8)
# dev.off()
