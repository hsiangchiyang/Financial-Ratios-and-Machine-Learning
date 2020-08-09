library(reticulate)
library(tensorflow)
library(keras)
library(e1071)
library(dplyr)
library(ggplot2)
library(tidyverse)
library(writexl)
require(readxl)
library(neuralnet)
require(neuralnet)
library(lubridate)
library(parallel)
library(lme4)

#set the working directory from which the files will be read from
setwd("PATH OF WORKDIR")
load("results.RData")
load("time_data.RData")

# accuracy helper
try_predict <- function(nn,test_dt,test_index){
  out <- tryCatch(
    {
      Predictions <- compute(nn,as.matrix(test_dt))
      prob <- Predictions$net.result
      prob <- as.matrix(prob)
      pred <- ifelse(prob>0.5, 1, 0)
      test_result <- data.frame()
      original <- test_dt$label3
      test_result <- data_frame(original)
      test_result$pred <- pred
      test_result$torf <- 0
      test_result$torf <- ifelse(test_result$pred == test_result$original, 1, 0)
      mean(test_result$torf)
    },
    error=function(cond) {
      return(0)
    },
    warning=function(cond) {
      return(0)
    },
    finally={
    }
  )
  return(out)
}

# split train, valid, and test
random_index <- sample(dim(time_data)[1])
num_train <- floor(0.7*dim(time_data)[1])
train_index <- random_index[1:num_train]
test_index <- random_index[num_train:dim(time_data)[1]]
#Testing
test_dt <- time_data[test_index,]
l_accs<-list()
for( i in 1:length(parallel_results)){
  l_accs[i] <- try_predict(parallel_results[[i]],test_dt,test_index)
}
l_accs_2<-as.data.frame(lapply(l_accs, unlist))
sorted_accs <- apply(l_accs_2, 1, sort)
sorted_accs <- rev(sorted_accs)
l_accs<-l_accs[!duplicated(l_accs)]
sorted_accs <- l_accs[order(sapply(l_accs,'[[',1))]
# Showing you top-8 accuracy
## Extract top 8 first
a<- sorted_accs[(length(sorted_accs)-7):length(sorted_accs)]
## Then pull them from the list of lists
b<- unique(rapply(a, function(x) head(x, 1)))
## Then re-order them in decreasing order
c<- sort(b, decreasing=TRUE)
l_accs<-list()
for( i in 1:length(parallel_results)){
  l_accs[i] <- try_predict(parallel_results[[i]],test_dt,test_index)
}

# Top nth models
MAX_TOP = 10
top_models <- list()
counter= 1
Total_counter = 1
while(Total_counter <= MAX_TOP){
  if(length(which(l_accs == c[counter])) > 1){
    #print("if")
    for ( i in 1:length(which(l_accs == c[counter])) ){
      #print((Total_counter+i)-1)
      if (((Total_counter+i)-1) > MAX_TOP){
        break
      }
      top_models[[(Total_counter+i)-1]] <- parallel_results[[which(l_accs == c[counter])[i]]]
    }
    counter = counter + 1
    Total_counter = Total_counter + length(which(l_accs == c[counter]))+1
  }
  else{
    #print("else")
    #print(Total_counter)
    top_models[[Total_counter]] <- parallel_results[[which(l_accs == c[counter])]]
    counter = counter + 1
    Total_counter = Total_counter + 1
  }
}

for (i in 1:length(top_models)){
  plot(top_models[[i]])
}

