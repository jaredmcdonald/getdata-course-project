# getdata-course-project

Course project for [Getting and Cleaning Data](https://class.coursera.org/getdata-032).

## Running the project

To run the analysis (will install `dplyr` if you don't already have it, download and unzip the raw dataset ([.zip](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)), and save a tidied version at `out/data.txt`; see `CodeBook.md` for variable descriptions):

```R
source('run_analyis.R')
run_analyis()
```

`run_analysis` does the following, in order:
- downloads and unzips the raw dataset (if it can't find the directory in the current working directory)
- reads in test and training datasets, filtering columns by measures of interest (means and standard deviations)
- adds columns for activity and subject factor variables to each dataset (mapping activity to a human-readable format)
- concatenates together the datasets
- groups the combined dataset by activity and subject
- summarizes the mean of the other variables for each activity / subject grouping
- saves the summary as a table at `out/data.txt`

More information on variables in `out/data.txt` can be found in `CodeBook.md`.

## Dependencies

Assumes R v3.2.1 or compatible and a public Internet connection.
