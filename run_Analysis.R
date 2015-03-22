
## Change this to the working directory that contains the UCI HAR dataset folder
setwd('valid path to UCI HAR dataset')


## This gets the list of files (with path) that need to be imported. 
train_files <- paste0('./train/',
                      list.files(path = './train',
                                 pattern='.*\\.txt'))
test_files <- paste0('./test/',
                     list.files(path = './test',
                                pattern='.*\\.txt'))

## this reads in the files grabbed above. 
trainread <- do.call('cbind',lapply(train_files,read.table))
testread <- do.call('cbind',lapply(test_files,read.table))

## bind the training and test sets together
merged <- rbind(trainread,testread)

## add the names into the dataset, grabbing the names from the features list
## in the HAR data folder use make.names and gsub to make them syntactically
## valid and easier to type
features <- read.table('./features.txt')
featnames <- gsub(pattern = '\\.{2}',
                  replacement = '',
                  make.names(features$V2))
namescol <- c('subject',featnames,'activity')
colnames(merged) <- namescol

## this grabs the indices of any of the features which have mean or std in their
## name then subset the data based on these results
meanfeatures <- grep(pattern = '.*mean.*',features$V2)
stdfeatures <- grep(pattern = '.*std.*',features$V2)
merged <- merged[,c(1,meanfeatures+1,stdfeatures+1,563)]

## this transforms activity from numbers to the names of the activites
activities <- read.table('./activity_labels.txt')
merged$activity <- as.factor(merged$activity)
levels(merged$activity) <- activities$V2

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

##write the tidy data set to a file
write.table(tidydata,'tidydata.txt',row.names=FALSE)
