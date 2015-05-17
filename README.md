---
title: "README"
output: html_document
---

The package submitted for this project contains the following files, which can be
downloaded from this Github repo <https://github.com/NawalElBoghdady/CleaningData>:

####1. ColCodes.txt                 
        => Contains the manually-defined codenames for each Feature vector.
####2. Modified_ColNames2.txt       
        => Contains the manually-defined descriptive Feature names.
####3. README.html 
        => HTML version of this document.
####4. README.md 
        => This document.
####5. README.Rmd 
        => R markdown version of this document.
####6. run_analysis.R 
        => R script that performs all necessary processing to extract the tidy data stored in Xout.txt
####7. Xout.txt 
        => File containing the tidy data set.
####8. Code Book.txt (xlsx, pdf)
        => Code book containing the description of each variable.
####9. UCI HAR Dataset 
        => Folder containing the raw data downloaded from <https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip>


================================================================================

###Here is how run_analysis.R works:

run_analysis.R processes the Samsung dataset according to the following criteria:

>1. Extracts only the measurements on the mean and standard deviation 
   for each measurement.
>2. Uses descriptive activity names to name the activities in the data set.
>3. Appropriately labels the data set with descriptive variable names.
>4. Merges the training and the test sets to create one data set.
>5. From the data set in step 4, creates a second, 
   independent tidy data set (called Xout) with the average of each variable for each 
   activity and each subject.
   
The following processing steps are applied:

####Step 0: Load all required libraries

####Step 1: Assemble the training dataset:
```
1. Read in the X_train data set, and select only measurements of mean and standardd deviation.
2. Label all Feature vectors with codenames.
3. Append the Activity vector (y_train) to X_train and replace each Activity number with its corresponding name.
4. Append Subject vector to X_train.
5. Sort X_train by Subject, and then by Activity.
```
####Step 2: Assemble the test dataset:
```
Follow the same procedure used to obtain the X_train data set, but this time use the test directory instead.
```

####Step 3: Merge the training and test data sets
####Step 4: Extract the tidy data set:
```
1. From the merged data set in Step 3, use a simple SQL query to obtain the average of each Feature column in the merged data frame (XMerged).
2. In the SQL query, you can specify that you want the output data frame (Xout) to be grouped by Subject, and Activity. That way, the mean of each Feature column can be obtained per Subject per Activity.
3. Sort Xout by Activity, and then by Subject. The first few entries of this data frame are shown below:

        
        ```
        ##   Subject Activity Mean Body Acceleration -X (Time Domain)
        ## 1       1   LAYING                               0.2215982
        ## 2       2   LAYING                               0.2813734
        ## 3       3   LAYING                               0.2755169
        ##   Mean Body Acceleration -Y (Time Domain)
        ## 1                             -0.04051395
        ## 2                             -0.01815874
        ## 3                             -0.01895568
        ```

4. Store that data frame in a text file (Xout.txt) using the write.table() function, with sep = "," and row.names = FALSE.
```



