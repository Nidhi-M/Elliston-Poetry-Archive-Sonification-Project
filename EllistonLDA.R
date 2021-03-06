library(rJava)
library(LDAvis)
library(mallet)
library(tm)
library(NLP)
library(ggplot2)
library(reshape2)

texts <- list()
data <- data.frame( x= character(), stringsAsFactors = F)
files <- list.files("C:/Users/mavaninm/DH-DS/Elliston Arizona Archive")
for ( file in files)
{
  con <- file(file,open="r")
  texts[file] <-  readChar(file, nchars = 1e6)
  data[file,1] <-  readChar(file, nchars = 1e6)
  close(con)
}

stopwords_en <- "C:/Users/mavaninm/DH-DS/R/Stopwords.txt"



###10 Topics and 100 iterations
NoOfTopics <- 10
model = MalletLDA(NoOfTopics)
instance = mallet.import(rownames(data),data$x, stoplist.file = stopwords_en)
model$loadDocuments(instance)

#HyperParameter optimization
model$setAlphaOptimization(20,40)
model$train(500)
phi = (mallet.topic.words(model, smoothed = TRUE, normalized = TRUE))
phi.count =mallet.topic.words(model, smoothed = TRUE, normalized = FALSE)
topic.counts = rowSums(mallet.topic.words(model, smoothed = TRUE, normalized = TRUE))
topic.proportions =  topic.counts/sum(topic.counts)
vocab = model$getVocabulary() 

topic.docs <- mallet.doc.topics(model, smoothed = TRUE, normalized = TRUE)

############################################################################################################################
##Plotting

json1 <- createJSON1( NoOfTopics,phi= phi,theta = topic.docs,vocab = vocab, term.frequency = topic.proportions)

##InterTopic Distance Map and Salient terms
serVis(json1, out.dir = 'vis101', open.browser = TRUE)
phi_df <- as.data.frame(phi)
row.names(phi_df) <- c(1:NoOfTopics)
colnames(phi_df) <- vocab

##Topic distribution for all the documents

topic.docs_df <- as.data.frame(topic.docs)
row.names(topic.docs_df ) <- rownames(data)
colnames(topic.docs_df) <- c(1:NoOfTopics)
topic.docs_df$Name <- row.names(topic.docs_df)

Melted_df <- melt(topic.docs_df, id.vars = "Name")

ggplot(Melted_df, aes(variable, value,  fill = variable)) + 
  facet_wrap(~ Name) +
  geom_bar(stat="identity", show_guide=FALSE)



###5 Topics and 100 iterations


NoOfTopics <- 5
model = MalletLDA(NoOfTopics)
instance = mallet.import(rownames(data),data$x, stoplist.file = stopwords_en)
model$loadDocuments(instance)

model$train(100)
phi = (mallet.topic.words(model, smoothed = TRUE, normalized = TRUE))
phi.count =mallet.topic.words(model, smoothed = TRUE, normalized = FALSE)
topic.counts = rowSums(mallet.topic.words(model, smoothed = TRUE, normalized = TRUE))
topic.proportions =  topic.counts/sum(topic.counts)
vocab = model$getVocabulary() 

topic.docs <- mallet.doc.topics(model, smoothed = TRUE, normalized = TRUE)

json1 <- createJSON1( NoOfTopics,phi= phi,theta = topic.docs,vocab = vocab, term.frequency = topic.proportions)

serVis(json1, out.dir = 'vis5', open.browser = TRUE)
phi_df <- as.data.frame(phi)
row.names(phi_df) <- c(1:NoOfTopics)
colnames(phi_df) <- vocab


topic.docs_df <- as.data.frame(topic.docs)
row.names(topic.docs_df ) <- rownames(data)
colnames(topic.docs_df) <- c(1:NoOfTopics)
topic.docs_df$Name <- row.names(topic.docs_df)

Melted_df <- melt(topic.docs_df, id.vars = "Name")

ggplot(Melted_df, aes(variable, value,  fill = variable)) + 
  facet_wrap(~ Name) +
  geom_bar(stat="identity", show_guide=FALSE)


## plot the word cloud for each topic make a shiny app? Perhaps this should be the end product
library(RColorBrewer)
library(wordcloud)

num.topics<-10
num.top.words<-50
for(i in 1:num.topics){
  topic.top.words <- mallet.top.words(model,phi[i,], 100)
  wordcloud(topic.top.words$words, topic.top.words$weights, c(4,.8), rot.per=0, random.order=F, pal)
}





























createJSON1 <- function (phi = matrix(), theta = matrix(), doc.length = integer(), 
                         vocab = character(), term.frequency = integer(), R = 30, 
                         lambda.step = 0.01, mds.method = jsPCA, cluster, plot.opts = list(xlab = "PC1", 
                                                                                           ylab = "PC2"), ...) 
{
  dp <- dim(phi)
  dt <- dim(theta)
  N <- sum(doc.length)
  W <- length(vocab)
  D <- length(doc.length)
  K <- dt[2]
  #if (dp[1] != K) 
  #stop("Number of rows of phi does not match \n      number of columns of theta; both should be equal to the number of topics \n      in the model.")
  #if (D != dt[1]) 
  # stop("Length of doc.length not equal \n      to the number of rows in theta; both should be equal to the number of \n      documents in the data.")
  #if (dp[2] != W) 
  # stop("Number of terms in vocabulary does \n      not match the number of columns of phi (where each row of phi is a\n      probability distribution of terms for a given topic).")
  #if (length(term.frequency) != W) 
  #stop("Length of term.frequency \n      not equal to the number of terms in the vocabulary.")
  if (any(nchar(vocab) == 0)) 
    stop("One or more terms in the vocabulary\n      has zero characters -- all terms must have at least one character.")
  phi.test <- all.equal(rowSums(phi), rep(1, K), check.attributes = FALSE)
  theta.test <- all.equal(rowSums(theta), rep(1, dt[1]), check.attributes = FALSE)
  #if (!isTRUE(phi.test)) 
  # stop("Rows of phi don't all sum to 1.")
  if (!isTRUE(theta.test)) 
    stop("Rows of theta don't all sum to 1.")
  topic.frequency <- colSums(theta * doc.length)
  topic.proportion <- topic.frequency/sum(topic.frequency)
  o <- order(topic.proportion, decreasing = TRUE)
  phi <- phi[o, ]
  theta <- theta[, o]
  topic.frequency <- topic.frequency[o]
  topic.proportion <- topic.proportion[o]
  mds.res <- mds.method(phi)
  if (is.matrix(mds.res)) {
    colnames(mds.res) <- c("x", "y")
  }
  else if (is.data.frame(mds.res)) {
    names(mds.res) <- c("x", "y")
  }
  else {
    warning("Result of mds.method should be a matrix or data.frame.")
  }
  mds.df <- data.frame(mds.res, topics = seq_len(K), Freq = topic.proportion * 
                         100, cluster = 1, stringsAsFactors = FALSE)
  term.topic.frequency <- phi * topic.frequency
  term.frequency <- colSums(term.topic.frequency)
  stopifnot(all(term.frequency > 0))
  term.proportion <- term.frequency/sum(term.frequency)
  phi <- t(phi)
  topic.given.term <- phi/rowSums(phi)
  kernel <- topic.given.term * log(sweep(topic.given.term, 
                                         MARGIN = 2, topic.proportion, `/`))
  distinctiveness <- rowSums(kernel)
  saliency <- term.proportion * distinctiveness
  default.terms <- vocab[order(saliency, decreasing = TRUE)][1:R]
  counts <- as.integer(term.frequency[match(default.terms, 
                                            vocab)])
  Rs <- rev(seq_len(R))
  default <- data.frame(Term = default.terms, logprob = Rs, 
                        loglift = Rs, Freq = counts, Total = counts, Category = "Default", 
                        stringsAsFactors = FALSE)
  topic_seq <- rep(seq_len(K), each = R)
  category <- paste0("Topic", topic_seq)
  lift <- phi/term.proportion
  find_relevance <- function(i) {
    relevance <- i * log(phi) + (1 - i) * log(lift)
    idx <- apply(relevance, 2, function(x) order(x, decreasing = TRUE)[seq_len(R)])
    indices <- cbind(c(idx), topic_seq)
    data.frame(Term = vocab[idx], Category = category, logprob = round(log(phi[indices]), 
                                                                       4), loglift = round(log(lift[indices]), 4), stringsAsFactors = FALSE)
  }
  lambda.seq <- seq(0, 1, by = lambda.step)
  if (missing(cluster)) {
    tinfo <- lapply(as.list(lambda.seq), find_relevance)
  }
  else {
    tinfo <- parallel::parLapply(cluster, as.list(lambda.seq), 
                                 find_relevance)
  }
  tinfo <- unique(do.call("rbind", tinfo))
  tinfo$Total <- term.frequency[match(tinfo$Term, vocab)]
  rownames(term.topic.frequency) <- paste0("Topic", seq_len(K))
  colnames(term.topic.frequency) <- vocab
  tinfo$Freq <- term.topic.frequency[as.matrix(tinfo[c("Category", 
                                                       "Term")])]
  tinfo <- rbind(default, tinfo)
  ut <- sort(unique(tinfo$Term))
  m <- sort(match(ut, vocab))
  tmp <- term.topic.frequency[, m]
  r <- row(tmp)[tmp >= 0.5]
  c <- col(tmp)[tmp >= 0.5]
  dd <- data.frame(Term = vocab[m][c], Topic = r, Freq = round(tmp[cbind(r, 
                                                                         c)]), stringsAsFactors = FALSE)
  dd[, "Freq"] <- dd[, "Freq"]/term.frequency[match(dd[, "Term"], 
                                                    vocab)]
  token.table <- dd[order(dd[, 1], dd[, 2]), ]
  RJSONIO::toJSON(list(mdsDat = mds.df, tinfo = tinfo, token.table = token.table, 
                       R = R, lambda.step = lambda.step, plot.opts = plot.opts, 
                       topic.order = o))
}
