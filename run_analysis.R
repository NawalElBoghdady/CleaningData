#run_analysis.R
################################################################################

#This script performs the following processing operations on the Samsung dataset:

#1. Extracts only the measurements on the mean and standard deviation 
#   for each measurement.
#2. Uses descriptive activity names to name the activities in the data set.
#3. Appropriately labels the data set with descriptive variable names.
#4. Merges the training and the test sets to create one data set.
#5. From the data set in step 4, creates a second, 
#   independent tidy data set with the average of each variable for each 
#   activity and each subject.

################################################################################

#0. Load required libraries:
#---------------------------
        library("data.table")
        library("sqldf")
        library("dplyr")

#===============================================================================

#I. Assemble the Training dataset:
#----------------------------------

        
        #Define column widths. Each column in the X_train dataset is fixed at a 
        #width of 16 chars:
        col_widths = 0*(1:561)+16
        
        #Read in column names:
        col_names = readLines(con = file("./UCI\ HAR\ Dataset/features.txt", encoding = "UTF8"))
        
        #Read in the X_train dataset:
        Xtrain = read.fwf("./UCI\ HAR\ Dataset/train/X_train.txt",  widths = col_widths, 
                          skip = 0, col.names = col_names)
        
        #Keep only the mean and std measurements:
        col_toBeKept = grep("mean|std",col_names)
        Xtrain2 = Xtrain[,col_toBeKept]
        
        #Store the column names in a file to edit them:
        #write(col_names[col_toBeKept],file = "Modified_ColNames.txt")
        
        #Read in manually-defined column codenames:
        new_col_names = readLines(con = file("./ColCodes.txt", encoding = "UTF8"))
        
        #Extract Activity names for each record:
        act_names = data.table(read.fwf("./UCI\ HAR\ Dataset/activity_labels.txt", widths = c(-2,20), 
                                        col.names = "Activity"))
        
        #Replace all underscores with spaces:
        act_names = sub("_"," ", act_names$Activity)
        
        #Add the Activity vector to Xtrain2: 
        ytrain = read.fwf("./UCI\ HAR\ Dataset/train/y_train.txt",  widths = 1, skip = 0, 
                          col.names = "Activity")
        Xtrain2 = data.frame(Activity = ytrain,Xtrain2)
        
        #Replace all Activity numbers with Activity names:
        for (i in 1:length(act_names))
        {
                Xtrain2$Activity = sub(sprintf("%s",i),act_names[i],Xtrain2$Activity)
                
        }
        
        
        #Add Subject information to Xtrain2:  
        subj = readLines(con = file("./UCI\ HAR\ Dataset/train/subject_train.txt", encoding = "UTF8"))     
        Xtrain2 = data.frame(Subject = subj, Xtrain2)
        
        #Arrange by Subject and Activity:
        Xtrain2 = arrange(Xtrain2,Subject,Activity)
        
        #Use feature codenames as column names:
        Xtrain2 = setnames(Xtrain2, old = names(Xtrain2[3:length(Xtrain2)]), 
                           new = new_col_names)

#===============================================================================

#II Assemble the Test dataset:
#------------------------------

        #Read in the test dataset:
        Xtest = read.fwf("./UCI\ HAR\ Dataset/test/X_test.txt",  widths = col_widths, 
                          skip = 0, col.names = col_names)
        
        #Keep only the mean and std measurements:
        Xtest2 = Xtest[,col_toBeKept]
        
        #Add the Activity vector to Xtest2: 
        ytest = read.fwf("./UCI\ HAR\ Dataset/test/y_test.txt",  widths = 1, skip = 0, 
                         col.names = "Activity")
        Xtest2 = data.frame(Activity = ytest,Xtest2)
        
        #Replace all Activity numbers with Activity names:
        for (i in 1:length(act_names))
        {
                Xtest2$Activity = sub(sprintf("%s",i),act_names[i],Xtest2$Activity)
                
        }
        
        
        #Add Subject information to Xtest2:
        subj = readLines(con = file("./UCI\ HAR\ Dataset/test/subject_test.txt", encoding = "UTF8")) 
        Xtest2 = data.frame(Subject = subj, Xtest2)
        
        #Arrange by Subject and Activity:
        Xtest2 = arrange(Xtest2,Subject,Activity)
        
        #Use feature codenames as column names:
        Xtest2 = setnames(Xtest2, old = names(Xtest2[3:length(Xtest2)]), 
                          new = new_col_names)
#===============================================================================

#III. Merge the two datasets:
#---------------------------

        #Merge training and test datasets by binding the rows in a single data
        #frame:
        XMerged = rbind(Xtrain2, Xtest2)
        
        #Sort the new data frame by Subject, and then by Activity name:
        XMerged = arrange(XMerged,Subject,Activity)

#===============================================================================

#IV. Create the tidy dataset with the average for each variable 
#     for every Activity and every Subject:
#------------------------------------------------------------


        #Create a string of all Feature names, and append the function AVG()
        #to each name. This can be used in a single SQL query to take the mean
        #of each feature for each subject for each activity:
        headings = toString(paste("AVG(", new_col_names, ")"))
        
        #Using the 'headings' string, and grouping the selected table by Subject
        #and Activity yields the required result:
        query = sprintf("SELECT Subject, Activity, %s
                FROM XMerged
                GROUP BY Subject, Activity", headings)
        Xout = sqldf(query)
        
        #Sort the output data frame by Activity, and then by Subject:
        Xout = arrange(Xout,Activity,as.numeric(as.character(Subject)))

        #Rename each Feature to a more descriptive name instead of using a codename.
        #Descriptive Feature names are read from a custom-made text file:
        new_col_names = readLines(con = file("./Modified_ColNames2.txt", encoding = "UTF8"))
        Xout = setnames(Xout, old = names(Xout[3:length(Xout)]), new = new_col_names)

        #Display output:
        View(Xout)
        
        #Store the final data frame as a text file using write.table(), with
        #row.names = FALSE:
        write.table(Xout, file = "Xout.txt", row.names = FALSE, quote = FALSE,
                    fileEncoding = "UTF8", sep = ",")

#===============================================================================
