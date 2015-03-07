# sqldf package allows to filter the file for the required records
require("sqldf")
library("sqldf")

zipUrl <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
zipFile <- "household_power_consumption.zip"
txtFile <- "household_power_consumption.txt"

# download and unzip the file if it is not in the working directory
if (!file.exists(txtFile)) {
  download.file(zipUrl, destfile = zipFile)
  unzip(zipFile)
}
# try to filter data from the file
subdata <- read.csv.sql("household_power_consumption.txt",sep=";",
                        sql = "select * from file where date in ('1/2/2007','2/2/2007')")

# if package could not be installed or loaded, following lines should be used
if (!exists("subdata")) {
  # Estimation of the memory the file needs
  mem_lim <- memory.limit()-memory.size()
  num.rows <- 2075259
  top.size <- object.size(read.csv("household_power_consumption.txt",sep = ";", 
                                   skip=1,nrow=1000))
  size.estimate <-  num.rows / 1000 * top.size
  if (size.estimate/(1024^2) > mem_lim) return -1
  
  hpc.file <- read.table("household_power_consumption.txt",sep = ";",header=TRUE,
                         na.strings = "?")
  # data filtering and transformation
  subdata <- hpc.file[hpc.file$Date == '1/2/2007' | hpc.file$Date == '2/2/2007',]
}

subdata$DateF <- strptime(subdata$Date,format = "%d/%m/%Y")

# Plot 3 specific data
subdata$Datetime <- strptime(paste(subdata$DateF,subdata$Time), format = "%Y-%m-%d %H:%M:%S")
subdata$Sub_metering_1 <- as.numeric(as.character(subdata$Sub_metering_1))
subdata$Sub_metering_2 <- as.numeric(as.character(subdata$Sub_metering_2))
subdata$Sub_metering_3 <- as.numeric(as.character(subdata$Sub_metering_3))

# Using Windows so if in other system, please use the correct device opener
if (Sys.info()["sysname"] == "Windows")
  windows(width = 1600,height = 1800)
#else if (Sys.info()["sysname"] == "unix")
#  x11()
#else if (Sys.info()["sysname"] == "Mac")
#  quartz()

# Uses this to ensure days are writen in English
# Sys.setlocale("LC_TIME", "English")

plot(subdata$Datetime,subdata$Sub_metering_1,type="l",xlab="",ylab="Energy sub metering")
points(subdata$Datetime,subdata$Sub_metering_2,type="l", col="red")
points(subdata$Datetime,subdata$Sub_metering_3,type="l", col="blue")
legend("topright",legend=c("Sub_metering_1","Sub_metering_2","Sub_metering_3"),
       lty=c(1,1,1), col=c("black","red","blue"))
dev.copy(png, file = "plot3.png")
dev.off()
