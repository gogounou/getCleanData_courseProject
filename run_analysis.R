## Check if data directory exists; create if it doesn't
if(!file.exists("./data")) {
        dir.create("./data")
}

## Download and unzip datafile
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zipFile <- "UCI-HAR_Dataset.zip"
download.file(fileURL, zipFile, method = "curl")
unzip(zipFile, exdir = "./data")

## Read all data sets
subjectTest <- read.table("./data/UCI HAR Dataset/test/subject_test.txt",
                          header = F, stringsAsFactors = F, fill = T)
xTest <- read.table("./data/UCI HAR Dataset/test/X_test.txt",
                    header = F, stringsAsFactors = F, fill = T)
yTest <- read.table("./data/UCI HAR Dataset/test/y_test.txt",
                    header = F, stringsAsFactors = F, fill = T)
subjectTrain <- read.table("./data/UCI HAR Dataset/train/subject_train.txt",
                           header = F, stringsAsFactors = F, fill = T)
xTrain <- read.table("./data/UCI HAR Dataset/train/X_train.txt",
                     header = F, stringsAsFactors = F, fill = T)
yTrain <- read.table("./data/UCI HAR Dataset/train/y_train.txt",
                     header = F, stringsAsFactors = F, fill = T)

## Merge all data sets. First combine similar tables
allSubject <- rbind(subjectTest, subjectTrain)
allY <- rbind(yTest, yTrain)
allX <- rbind(xTest, xTrain)

## Now concatenate combined tables
allData <- cbind(allSubject, allY, allX)

## Add names to columns from allSubject and allY
colnames(allData)[1:2] <- c("Subject", "Activity")

## Import features.txt file for use as allX column names
xNames <- read.table("./data/UCI HAR Dataset/features.txt",
                     header = F, stringsAsFactors = F, fill = T)

## Add names to allXcolumns from imported file
colnames(allData)[3:563] <- xNames[, 2]

## Extract only the mean and standard deviation for each measurement.
## Note: specifically suppressing "meanFreq" columns, as these are
## included in the call for "mean()" for some reason. 
selectData <- allData[, grepl("mean()|std()|Activity|Subject",
                                 colnames(allData)) &
                                 !grepl("meanFreq",colnames(allData))]

## Apply descriptive activity names to the activities in the dataset.
## First, import activity names from activity_labels.txt
activities <- read.table("./data/UCI HAR Dataset/activity_labels.txt",
                         header = F, stringsAsFactors = F, fill = T)

## Now, replace activity id with the activity name from the label file
selectData$Activity <- activities[,2][match(selectData$Activity,activities[,1])]

## From this last data, creates a second, independent tidy data set with the 
## average of each variable for each activity and each subject.
library(plyr)
tidyData <- ddply(selectData,
                  .(Subject, Activity),
                  .fun=function(x) { colMeans(x[ ,-c(1:2)]) })

## Write data to text file for project submission
write.csv(tidyData, "./data/getCleanData_project.txt", row.names = FALSE)