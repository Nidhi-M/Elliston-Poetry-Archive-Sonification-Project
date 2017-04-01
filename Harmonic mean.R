library(topicmodels)
#
# get some of the example data that's bundled with the package
#
data("AssociatedPress", package = "topicmodels")

harmonicMean <- function(logLikelihoods, precision=2000L) {
  library("Rmpfr")
  llMed <- median(logLikelihoods)
  as.double(llMed - log(mean(exp(-mpfr(logLikelihoods,
                                       prec = precision) + llMed))))
}

# The log-likelihood values are then determined by first fitting the model using for example
k = 5
burnin = 100
iter = 1000
keep = 50

fitted <- LDA(train_data, k = k, method = "Gibbs",control = list(burnin = burnin, iter = iter, keep = keep) )

# where keep indicates that every keep iteration the log-likelihood is evaluated and stored. This returns all log-likelihood values including burnin, i.e., these need to be omitted before calculating the harmonic mean:

logLiks <- fitted@logLiks[-c(1:(burnin/keep))]

# assuming that burnin is a multiple of keep and

harmonicMean(logLiks)

library(topicmodels)
#
# get some of the example data that's bundled with the package
#
data("AssociatedPress", package = "topicmodels")

harmonicMean <- function(logLikelihoods, precision=2000L) {
  library("Rmpfr")
  llMed <- median(logLikelihoods)
  as.double(llMed - log(mean(exp(-mpfr(logLikelihoods,
                                       prec = precision) + llMed))))
}

# The log-likelihood values are then determined by first fitting the model using for example
k = 10
burnin = 100
iter = 1000
keep = 50

fitted <- LDA(train_data, k = k, method = "Gibbs",control = list(burnin = burnin, iter = iter, keep = keep) )

# where keep indicates that every keep iteration the log-likelihood is evaluated and stored. This returns all log-likelihood values including burnin, i.e., these need to be omitted before calculating the harmonic mean:

logLiks <- fitted@logLiks[-c(1:(burnin/keep))]

# assuming that burnin is a multiple of keep and

harmonicMean(logLiks)