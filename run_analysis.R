# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

######Load Packages and get the Data############

library(dplyr)
library(tidyr)
library(data.table)
path <- getwd()
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(path, "dataFiles.zip"))
unzip(zipfile = "dataFiles.zip")

##### Load activity labels & features###########
activityLabels <- fread(file.path(path, "UCI HAR Dataset/activity_labels.txt")
                        , col.names = c("classLabels", "activityName"))
features <- fread(file.path(path, "UCI HAR Dataset/features.txt")
                  , col.names = c("index", "featureNames"))
featuresWanted <- grep("(mean|std)\\(\\)", features$featureNames)
measurements <- features[featuresWanted, featureNames]
measurements <- gsub("[()]", " ", measurements)


###### Load train datasets######
train <- fread(file.path(path, "UCI HAR Dataset/train/X_train.txt"))
train <- select(train, featuresWanted)
setnames(train, names(train), measurements)
trainActivities <- fread(file.path(path, "UCI HAR Dataset/train/Y_train.txt")
                         , col.names = c("Activity"))
trainSubjects <- fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt")
                       , col.names = c("SubjectNum"))
train <- mutate(train, Activities = trainActivities$Activity, Subjects = trainSubjects$SubjectNum)


###### Load test datasets########
test <- fread(file.path(path, "UCI HAR Dataset/test/X_test.txt"))
test <- select(test, featuresWanted)
setnames(test, names(test), measurements)
testActivities <- fread(file.path(path, "UCI HAR Dataset/test/Y_test.txt")
                        , col.names = c("Activity"))
testSubjects <- fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt")
                      , col.names = c("SubjectNum"))
test <- mutate(test, Activities = testActivities$Activity, Subjects = testSubjects$SubjectNum)

# merge datasets
combined <- rbind(train, test)

# Convert classLabels to activityName. Create as factor 
combined <- mutate(combined, Activities = factor(combined$Activities
                                 , levels = activityLabels$classLabels
                                 , labels = activityLabels$activityName))

#Make Subjects a factor
combined$Subjects <- as.factor(combined$Subjects)


#Melt down data by Subjects and Activities
combinedmelt <- melt(combined, id.vars = c("Subjects", "Activities"))
#Cast Data and take average of all other variables
combineddata <- dcast(combinedmelt, Subjects + Activities ~ variable, fun.aggregate = mean)

#Create text file data set
data.table::fwrite(x = combineddata, file = "tidyData.txt", quote = FALSE)


