## libraries
if (!'dplyr' %in% installed.packages()) {
    message('installing dplyr')
    install.packages('dplyr')
}
library(dplyr)

## constants
BASE_DATA_DIR = 'UCI HAR Dataset'
DATA_URI = 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
OUTFILE_DIRNAME = 'out'
OUTFILE_NAME = 'data.txt'

## download and unzip data, if we haven't already
fetch_data <- function () {
    if (!dir.exists(BASE_DATA_DIR)) {
        message('data not found in project directory; downloading and unzipping to ',
                file.path(getwd(), BASE_DATA_DIR))
        temp <- tempfile()
        download.file(DATA_URI, temp)
        unzip(temp)
        unlink(temp)
    }
}
## write data to disk
write_to_disk <- function (d) {
    if (!dir.exists(OUTFILE_DIRNAME)) {
        message('creating directory ', file.path(getwd(), OUTFILE_DIRNAME))
        dir.create(OUTFILE_DIRNAME)
    }
    combined <- file.path(OUTFILE_DIRNAME, OUTFILE_NAME)
    message('Saving tidied data to ', file.path(getwd(), combined))
    write.table(d, combined, row.names = FALSE)
}

## get a vector of indices of which features to extract
## extract mean() and std() measures
get_col_vector <- function (feature_names) {
    grep('(mean|std)\\(\\)', feature_names[, 2])
}

## functions for reading from disk into memory
## feature labels
get_feature_labels <- function () {
    read.table(file.path(BASE_DATA_DIR, 'features.txt'))
}
## activity labels
get_activity_labels <- function () {
    read.table(file.path(BASE_DATA_DIR, 'activity_labels.txt'))[, 2]
}
## row to activity mapping
get_activity_mapping <- function (which_set) {
    read.table(file.path(BASE_DATA_DIR, which_set, paste0('y_', which_set, '.txt')))[, 1]
}
## row to subject mapping
get_subject_mapping <- function (which_set) {
    read.table(file.path(BASE_DATA_DIR, which_set, paste0('subject_', which_set, '.txt')))[, 1]
}
## grab and filter dataset on columns of interest
get_data <- function (which_set, cols) {
    read.table(file.path(BASE_DATA_DIR, which_set, paste0('X_', which_set, '.txt'))) %>%
        select(cols)
}

## get a dataset, add colnames, and associate activity and subject factor columns
get_dataset_with_labels <- function (which_set, cols, feature_labels, activity_labels) {
    data <- get_data(which_set, cols)
    colnames(data) <- feature_labels
    assoc_activities_with_dataset(data, activity_labels, which_set) %>%
        assoc_subject_with_dataset(which_set)
}

## tidy up the feature labels and return a vector
build_feature_labels <- function (features, col_vector) {
    gsub('[\\(\\)]', '', features[col_vector, 2])
}

## functions to associate new columns with dataset
## add a column for `activity` factor, mapped to human-readable names
## (e.g. "WALKING" instead of 1)
assoc_activities_with_dataset <- function (dataset, activity_labels, which_set) {
    mutate(dataset, activity = sapply(get_activity_mapping(which_set),
                                      function (i) activity_labels[i]))
}
## add a column for `subject` factor
assoc_subject_with_dataset <- function (dataset, which_set) {
    mutate(dataset, subject = as.factor(get_subject_mapping(which_set)))
}

## initialize and run analysis
run_analysis <- function () {
    # grab data, if we don't already have it
    fetch_data()
    
    # store feature labels table
    all_features <- get_feature_labels()
    # get columns of interest (means and standard deviations)
    col_vector <- get_col_vector(all_features)
    # get the labels for said columns
    feature_labels <- build_feature_labels(all_features, col_vector)
    
    # store activity table
    activity_labels <- get_activity_labels()
    
    # get datasets and rbind them together
    rbind(get_dataset_with_labels('train', col_vector, feature_labels, activity_labels),
          get_dataset_with_labels('test', col_vector, feature_labels, activity_labels)) %>%
        # then group by activity and subject
        group_by(activity, subject) %>%
        # compress the other rows to their mean
        summarize_each(funs(mean)) %>%
        # and finally, write the simplified dataset to disk
        write_to_disk()
}
