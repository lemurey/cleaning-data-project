

###Introduction

This assignment was to create a tidy data set from accelerometer data available
from [UCI](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip) 
more information on this dataset is available [here](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones).
The assignment gave five instructions:

 
1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each 
measurement. 
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names. 
5. From the data set in step 4, creates a second, independent tidy data set 
with the average of each variable for each activity and each subject.  

In this document I will walk you through my solution to the is problem and 
provide the information needed to recreate my solution from the raw data. In 
the same github repository as this document there is a file called 
run_Analysis.R. The rest of this document will go through that code step by 
step and detail how to create the tidydata.txt file.

###Loading the initial data


```r
## Change this to the working directory that contains the UCI HAR dataset folder
setwd('valid path to UCI HAR dataset')
```
In order for the run_Analysis.R file to work the path at the beginning of the
document must be altered to contain the path to the folder UCI HAR dataset 
which is contained in the zip directory linked to above. All other paths are set
relative to this directory, so without the proper path set initially the code 
will not run.

After setting the correct path the next step is to generate the list of files
which contain the data to be collected and summarized. These files are in the
train and test folders respectively. There is an even rawer form of the data 
contained in the Inertial Signals subfolders, but that was ignored for this 
analysis.  

```r
train_files <- paste0('./train/',
                      list.files(path = './train',
                                 pattern='.*\\.txt'))
test_files <- paste0('./test/',
                     list.files(path = './test',
                                pattern='.*\\.txt'))
```
By passing the pattern option to list.files you can subset the output based on
a regular expression. The one used above only grabs files with a .txt extension
to read in. I am assuming that no additional .txt files have been added to these
folders since they were unzipped.  

```r
## this reads in the files grabbed above. 
trainread <- do.call('cbind',lapply(train_files,read.table))
testread <- do.call('cbind',lapply(test_files,read.table))
```
The next step is to read in the data we want to analyze. The do.call function
creates a function call to its first argument. In this way I can create a call
to cbind after reading in each data file in train_files and test_files.  

###Merging the Test and Training Set and settign descriptive variable names


```r
## add the names into the dataset, grabbing the names from the features list
## in the HAR data folder use make.names and gsub to make them syntactically
## valid and easier to type
features <- read.table('./features.txt')
featnames <- gsub(pattern = '\\.{2}',
                  replacement = '',
                  make.names(features$V2))
namescol <- c('subject',featnames,'activity')
colnames(merged) <- namescol
```
After reading in the files I create a merged dataset of the training and test
data. This satisfies point 1 of the instructions. I then rename the columns
based on their content. The feature names are extracted from the features 
provided by the features.txt file. Using make.names replaces the - and () in
the original variable names with . to make them syntactically valid. After this
I run the names through gsub and replace the ... with . to remove the excess dots.
These feature names are used to name the columns as well as using the subject 
label for subject ID numbers and the activity label for the activities. 
This satisfies point 4 of the assignment.  

###Adding descriptive activity names  


```r
## this grabs the indices of any of the features which have mean or std in their
## name then subset the data based on these results
meanfeatures <- grep(pattern = '.*mean.*',features$V2)
stdfeatures <- grep(pattern = '.*std.*',features$V2)
merged <- merged[,c(1,meanfeatures+1,stdfeatures+1,563)]

## this transforms activity from numbers to the names of the activites
activities <- read.table('./activity_labels.txt')
merged$activity <- as.factor(merged$activity)
levels(merged$activity) <- activities$V2
```
This block of code subsets the combined data based on the variables which have
mean or std in their names. I decided to be as expansive as possible in my 
definition of which variables are to be taken to satisfy point 2 of the 
assignment. I need to add 1 to the indices calculated with grep beacuase I have
left bound the subject columns. I grab the first and last columns in addition to
the grep results because they contain the important subject ID and activity 
values.  

###Creating a tidy data set


```r
## here we create the tidy data set
tidydata <- NULL
for (i in 1:30) {
     tempdata <- merged[merged$subject==i,]
     tempvals <- aggregate(tempdata[,-81],
                           list('activity' = tempdata$activity),
                           mean)
     tidydata <- rbind(tidydata,tempvals)
}

## add on a marker of which data came from the test or training set
trainsub <- unique(read.table('./train/subject_train.txt'))
testsub <- unique(read.table('./test/subject_test.txt'))
tidydata$dataset[tidydata$subject %in% trainsub$V1] <- 'train'
tidydata$dataset[tidydata$subject %in% testsub$V1] <- 'test'
```
Finally I create the tidy data set by looping through the subject ID's and then
calculating the mean for each activity with the aggregate function. After 
generating this tidy data set I add on the indicators of whether the subject was
in the test or training set to begin with. This satisfies point 5 of the 
assignment.

```r
##write the tidy data set to a file
write.table(tidydata,'tidydata.txt',row.names=FALSE)
```
The final piece of code writes the tidy data set to a text file. The easiest 
way to examine this tidy data set is to load it back into R with the following
command, and then view it with the view function.

```r
tidydata <- read.table('tidydata.txt',header=TRUE)
```
