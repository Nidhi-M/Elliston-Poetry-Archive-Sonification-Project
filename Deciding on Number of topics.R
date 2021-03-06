# Load up R packages including a few we only need later:
library(topicmodels)
library(doParallel)
library(ggplot2)
library(scales)
library(tidyverse)
library(RColorBrewer)
library(wordcloud)
library(NLP)
library(tm)
library(ldatuning)
library(reshape2)

data <- data.frame( x= character(), stringsAsFactors = F)
files <- list.files("C:/Users/mavaninm/DH-DS/Elliston Arizona Archive")
for ( file in files)
{
  con <- file(file,open="r")
  texts[file] <-  readChar(file, nchars = 1e6)
  data[file,1] <-  readChar(file, nchars = 1e6)
  close(con)
}


set.seed(12345) 
sampling <- sample(1:23, replace = FALSE,size = nrow(data)*0.8 )
train_data <- data[sampling,]

test_data <- data[-sampling,]
##Creating the document-term matrix for train data
doc.vec_train <- VectorSource(train_data)
doc.corpus_train <- Corpus(doc.vec)
doc.corpus_train <- tm_map(doc.corpus_train , tolower)
doc.corpus_train <- tm_map(doc.corpus_train, removePunctuation)
doc.corpus_train <- tm_map(doc.corpus_train, removeNumbers)
doc.corpus_train <- tm_map(doc.corpus_train, removeWords, stopwords("english"))
doc.corpus_train <- tm_map(doc.corpus_train, stripWhitespace)

TDM_train <- TermDocumentMatrix(doc.corpus_train)
DTM_train <- DocumentTermMatrix(doc.corpus_train)

##Creating the document term matrix for test data
doc.vec_test <- VectorSource(test_data)
doc.corpus_test  <- Corpus(doc.vec_test)
doc.corpus_test  <- tm_map(doc.corpus_test, tolower)
doc.corpus_test  <- tm_map(doc.corpus_test, removePunctuation)
doc.corpus_test  <- tm_map(doc.corpus_test, removeNumbers)
doc.corpus_test  <- tm_map(doc.corpus_test, removeWords, stopwords("english"))
doc.corpus_test  <- tm_map(doc.corpus_test, stripWhitespace)

TDM_test <- TermDocumentMatrix(doc.corpus_test)
DTM_test <- DocumentTermMatrix(doc.corpus_test)

##plot the metrics to get number of topics
system.time({
  tunes <- FindTopicsNumber(
    dtm = DTM_train,
    topics = c(1:15),
    metrics = c("Griffiths2004", "CaoJuan2009", "Arun2010"),
    method = "Gibbs",
    control = list(seed = 12345),
    mc.cores = 4L,
    verbose = TRUE
  )
})
FindTopicsNumber_plot(tunes)


##Using perplexity for hold out set
perplexity_df <- data.frame(train=numeric(), test=numeric())
topics <- c(2:15)
burnin = 100
iter = 1000
keep = 50

set.seed(12345)
for (i in topics){
 
  fitted <- LDA(DTM_train, k = i, method = "Gibbs",
                control = list(burnin = burnin, iter = iter, keep = keep) )
  perplexity_df[i,1] <- perplexity(fitted, newdata = DTM_train)
  perplexity_df[i,2]  <- perplexity(fitted, newdata = DTM_test) 
}


##plotting the perplexity of both train and test

g <- ggplot(data=perplexity_df, aes(x= as.numeric(row.names(perplexity_df)))) + labs(y="Perplexity",x="Number of topics") + ggtitle("Perplexity of hold out  and training data")

g <- g + geom_line(aes(y=test), colour="red")
g <- g + geom_line(aes(y=train), colour="green")
g


#----------------5-fold cross-validation, different numbers of topics----------------

doc.vec <- VectorSource(unlist(data))
doc.corpus  <- Corpus(doc.vec)
doc.corpus  <- tm_map(doc.corpus, tolower)
doc.corpus  <- tm_map(doc.corpus, removePunctuation)
doc.corpus  <- tm_map(doc.corpus, removeNumbers)
doc.corpus  <- tm_map(doc.corpus, removeWords, stopwords("english"))
doc.corpus  <- tm_map(doc.corpus, stripWhitespace)

TDM <- TermDocumentMatrix(doc.corpus)
DTM <- DocumentTermMatrix(doc.corpus)
cluster <- makeCluster(detectCores(logical = TRUE) - 1) # leave one CPU spare...
registerDoParallel(cluster)

clusterEvalQ(cluster, {
  library(topicmodels)
})

folds <- 5
splitfolds <- sample(1:folds, 23, replace = TRUE)
candidate_k <- c(2:15) # candidates for how many topics
clusterExport(cluster, c("full_data", "burnin", "iter", "keep", "splitfolds", "folds", "candidate_k"))

# we parallelize by the different number of topics.  A processor is allocated a value
# of k, and does the cross-validation serially.  This is because it is assumed there
# are more candidate values of k than there are cross-validation folds, hence it
# will be more efficient to parallelise
system.time({
  results <- foreach(j = 1:length(candidate_k), .combine = rbind) %dopar%{
    k <- candidate_k[j]
    results_1k <- matrix(0, nrow = folds, ncol = 2)
    colnames(results_1k) <- c("k", "perplexity")
    for(i in 1:folds){
      train_set <- DTM[splitfolds != i , ]
      valid_set <- DTM[splitfolds == i, ]
      
      fitted <- LDA(train_set, k = k, method = "Gibbs",
                    control = list(burnin = burnin, iter = iter, keep = keep) )
      results_1k[i,] <- c(k, perplexity(fitted, newdata = valid_set))
    }
    return(results_1k)
  }
})
stopCluster(cluster)

results_df <- as.data.frame(results)

ggplot(results_df, aes(x = k, y = perplexity)) +
  geom_point() +
  geom_smooth(se = FALSE) +
  ggtitle("5-fold cross-validation of topic modeling with the Elliston dataset",
          "(ie five different models fit for each candidate number of topics)") +
  labs(x = "Candidate number of topics", y = "Perplexity when fitting the trained model to the hold-out set")






