library(xlsx)
library(rJava)
library(xlsxjars)
#the collection can be found at 
#https://drc.libraries.uc.edu/handle/2374.UC/695985/browse?value=The+Elliston+Project+%3A+Poetry+Readings&type=series&ztype=series
#read the excel which had all the name of authors (75 as of dec 2016)

## The purpose of this is to analyze different software for Speech to text conversion. Thus  a random sample of poets to quantify the performance of software.
authors <- read.xlsx(file="D:/GA/ListOfAuthors.xlsx", sheetName = "Sheet2")

#Sampling the authors randomly by setting the seed to 10 to make it reproducible
set.seed(11)
Samples <- sample(1:75, size=11)
SelectedAuthors <- authors[Samples,]

SelectedAuthors <- as.data.frame((SelectedAuthors))
 
NotSelected <- authors[-Samples,]
NotSelected <- as.data.frame(NotSelected)

## Select next 10 authors

set.seed(11)
Samples2 <- sample(1:64, size=10)
SelectedAuthors2 <-  NotSelected[Samples2,]
SelectedAuthors2 <- as.data.frame((SelectedAuthors2))
