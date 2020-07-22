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
rawdata <- read_excel("realannual.xlsx")
rawdata_r <- subset(rawdata, select=c('datadate','indfmt','tic','conm','acox','acoxar','act','ap','at','che','ch','cogs','dclo','dcvt','dcvsub','dcvsr','dd1','dlc','dltt','dlto','dn','ds','gp','ib','invrm','invwip','invfg','invt','invo','ivst','itcb', 'lco','lcoxar','lcox','lct','lo','lse','lt','np','oancf','oibdp','prcc_c','prch_c','prcl_c','mkvalt','recco','rect','rectr','revt','seq','tdst','txp','txr','udd','xacc','xint','xpp','xsga'))
# filtering NA in prcc_c
rawdata_r <- rawdata_r[complete.cases(rawdata_r$prcc_c), ]

# Cash or Equivalent
rawdata_r$ch<-ifelse(is.na(rawdata_r$ch), 0, rawdata_r$ch)
rawdata_r$ivst<-ifelse(is.na(rawdata_r$ivst), 0, rawdata_r$ivst==rawdata_r$ivst)
rawdata_r$che<-ifelse(is.na(rawdata_r$che), rowSums(rawdata_r[,c('ch', 'ivst')]), rawdata_r$che)
rawdata_r$che<-ifelse(rawdata_r$che==0, rowSums(rawdata_r[,c('ch', 'ivst')]), rawdata_r$che)
# Other current assets
rawdata_r$acox<-ifelse(is.na(rawdata_r$acox),0,rawdata_r$acox)
rawdata_r$acoxar<-ifelse(is.na(rawdata_r$acoxar), rawdata_r$acox, rawdata_r$acoxar)
rawdata_r$xpp<-ifelse(is.na(rawdata_r$xpp), 0, rawdata_r$xpp)
# Current receivables
rawdata_r$rectr<-ifelse(is.na(rawdata_r$rectr), 0, rawdata_r$rectr)
rawdata_r$recco<-ifelse(is.na(rawdata_r$recco), 0, rawdata_r$recco)
rawdata_r$txr<-ifelse(is.na(rawdata_r$txr), 0, rawdata_r$txr)
rawdata_r$rect<-ifelse(is.na(rawdata_r$rect), rowSums(rawdata_r[,c('rectr', 'recco','txr')]), rawdata_r$rect)
rawdata_r$rect<-ifelse(rawdata_r$rect==0, rowSums(rawdata_r[,c('rectr', 'recco','txr')]), rawdata_r$rect)
# Current inventories
rawdata_r$invrm<-ifelse(is.na(rawdata_r$invrm), 0, rawdata_r$invrm)
rawdata_r$invwip<-ifelse(is.na(rawdata_r$invwip), 0, rawdata_r$invwip)
rawdata_r$invfg<-ifelse(is.na(rawdata_r$invfg), 0, rawdata_r$invfg)
rawdata_r$invo<-ifelse(is.na(rawdata_r$invo), 0, rawdata_r$invo)
rawdata_r$invt<-ifelse(is.na(rawdata_r$invt), rowSums(rawdata_r[,c('invrm','invwip','invfg','invo')]), rawdata_r$invt)
rawdata_r$invt<-ifelse(rawdata_r$invt==0, rowSums(rawdata_r[,c('invrm','invwip','invfg','invo')]), rawdata_r$invt)
summary(rawdata_r$invt)
# Current Asset
rawdata_r$act<-ifelse(is.na(rawdata_r$act),rowSums(rawdata_r[,c('acoxar', 'che', 'invt', 'rect')]),rawdata_r$act)
rawdata_r$act<-ifelse(rawdata_r$act==0,rowSums(rawdata_r[,c('acoxar', 'che', 'invt', 'rect')]),rawdata_r$act)
summary(rawdata_r$act)
# Long Term Debt - Total
rawdata_r$dcvsub<-ifelse(is.na(rawdata_r$dcvsub), 0, rawdata_r$dcvsub) #A
rawdata_r$dcvsr<-ifelse(is.na(rawdata_r$dcvsr), 0, rawdata_r$dcvsr) #B
rawdata_r$dcvt<-ifelse(is.na(rawdata_r$dcvt), rowSums(rawdata_r[,c('dcvsub','dcvsr')]), rawdata_r$dcvt) #C = A+B
rawdata_r$dcvt<-ifelse(rawdata_r$dcvt==0, rowSums(rawdata_r[,c('dcvsub','dcvsr')]), rawdata_r$dcvt) #C = A+B
rawdata_r$dn<-ifelse(is.na(rawdata_r$dn), 0, rawdata_r$dn)
rawdata_r$ds<-ifelse(is.na(rawdata_r$ds), 0, rawdata_r$ds)
rawdata_r$udd<-ifelse(is.na(rawdata_r$udd), 0, rawdata_r$udd)
rawdata_r$dlto<-ifelse(is.na(rawdata_r$dlto), 0, rawdata_r$dlto)
rawdata_r$dclo<-ifelse(is.na(rawdata_r$dclo), 0, rawdata_r$dclo)
rawdata_r$dltt<-ifelse(is.na(rawdata_r$dltt), rowSums(rawdata_r[,c('dcvt','dn','ds','dlto','dclo','udd')]), rawdata_r$dltt)
rawdata_r$dltt<-ifelse(rawdata_r$dltt==0, rowSums(rawdata_r[,c('dcvt','dn','ds','dlto','dclo','udd')]), rawdata_r$dltt)
# Account payable (ap)
rawdata_r$ap<-ifelse(is.na(rawdata_r$ap), 0, rawdata_r$ap)
# Debt in current liabilities - Total (dlc)
rawdata_r$dd1<-ifelse(is.na(rawdata_r$dd1), 0, rawdata_r$dd1)
rawdata_r$np<-ifelse(is.na(rawdata_r$np), 0, rawdata_r$np)
rawdata_r$dlc<-ifelse(is.na(rawdata_r$dlc), rowSums(rawdata_r[,c('dd1', 'np')]), rawdata_r$dlc)
# Current Liabilities Other Total (lco)
rawdata_r$lcox<-ifelse(is.na(rawdata_r$lcox), 0, rawdata_r$lcox)
rawdata_r$xacc<-ifelse(is.na(rawdata_r$xacc), 0, rawdata_r$xacc)
rawdata_r$lco<-ifelse(is.na(rawdata_r$lco), rowSums(rawdata_r[,c('lcox', 'xacc')]), rawdata_r$lco)
# Income Taxes payable (txp)
rawdata_r$txp<-ifelse(is.na(rawdata_r$txp), 0, rawdata_r$txp)
# Current liabilities
rawdata_r$lct<-ifelse(is.na(rawdata_r$lct),rowSums(rawdata_r[,c('ap', 'dlc', 'lco', 'txp')]),rawdata_r$lct)
summary(rawdata_r$lct)
# Operating Income Before Depreciation (oibdp)
rawdata_r$xsga<-ifelse(is.na(rawdata_r$xsga), 0, rawdata_r$xsga)
rawdata_r$gp<-ifelse(is.na(rawdata_r$gp), 0, rawdata_r$gp)
rawdata_r$oibdp<-ifelse(is.na(rawdata_r$oibdp), (rawdata_r$gp-rawdata_r$xsga), rawdata_r$oibdp)
rawdata_r$oibdp<-ifelse(rawdata_r$oibdp==0, (rawdata_r$gp-rawdata_r$xsga), rawdata_r$oibdp)
# Interest Expenses
rawdata_r$xint<-ifelse(is.na(rawdata_r$xint), 0, rawdata_r$xint)
# length, number of rows, unique names in rawdata_r
length(rawdata_r)
nrow(rawdata_r)
unique(rawdata_r$conm)
# company to factors
rawdata_r$conm<-as.factor(rawdata_r$conm)
levels(rawdata_r$conm)
# You can also find the names of companies by the command below
unique(rawdata$conm)
just_i<-subset(rawdata_r, indfmt=="INDL")

# Current ratio
just_i$current_ratio<-just_i$act/just_i$lct
# Quick ratio
just_i$quick_ratio<-(just_i$act-just_i$invt-just_i$xpp)/just_i$lct
summary(just_i$quick_ratio)
# Cash Ratio
just_i$cash_ratio<-just_i$che/just_i$lct
# Operating Cash Flow Ratio
just_i$ocf_ratio<-just_i$oancf/just_i$lct
# Debt Ratio
just_i$debt_ratio<-just_i$dltt/just_i$lse
summary(just_i$debt_ratio)
# Debt-to-equity ratio
just_i$de_ratio<-just_i$dltt/just_i$seq
summary(just_i$de_ratio)
# Interest Coverage Ratio
just_i$ic_ratio<-just_i$oibdp/just_i$xint
summary(just_i$ic_ratio)
# Debt service coverage ratio
just_i$dsc_ratio<-just_i$oibdp/just_i$dd1
summary(just_i$dsc_ratio)
# Asset turnover ratio
just_i$at_ratio<-just_i$oibdp/just_i$at
summary(just_i$at_ratio)
# Inventory turnover ratio
just_i$it_ratio<-just_i$cogs/just_i$invt
summary(just_i$it_ratio)
# Gross Margin ratio
just_i$gm_ratio<-just_i$gp/just_i$revt
summary(just_i$gm_ratio)
# Operating margin ratio
just_i$om_ratio<-just_i$oibdp/just_i$revt
summary(just_i$om_ratio)
# Return on Assets ratio
just_i$roa_ratio<-just_i$ib/just_i$at
summary(just_i$roa_ratio)
just_i_ratio<-just_i[,c('datadate','tic','conm','prcc_c','current_ratio','quick_ratio','cash_ratio','ocf_ratio','debt_ratio','de_ratio','ic_ratio','dsc_ratio','at_ratio','it_ratio','gm_ratio','om_ratio','roa_ratio')]

# Counter a number of "NA" per row
just_i_ratio$na_count <- rowSums(is.na(just_i_ratio))
just_i_ratio<-just_i_ratio[!(just_i_ratio$na_count>=5),]

# Create labels
just_i_ratio$label <- 0
just_i_ratio$avg_prcc_c <-0
all_comn <- unique(just_i_ratio$conm)
mod_data <- data_frame()

for (i in 1:length(unique(all_comn))){
  cur_comn <- subset(just_i_ratio, conm==all_comn[i])
  for (j in  1:length(cur_comn$prcc_c)){
    
    if (j < length(cur_comn$prcc_c)){
      cur_comn$avg_prcc_c[j+1] <- mean(cur_comn$prcc_c[1:j])
    }

    if (j > 1 & cur_comn$prcc_c[j] >= cur_comn$avg_prcc_c[j]){
      cur_comn$label[j-1] <- 1
    }
  }
  
  mod_data <- rbind(mod_data,cur_comn[3:length(cur_comn$prcc_c)-1,])

}

#Drop unused
fil<-mod_data %>% filter_all(all_vars(!is.infinite(.)))
fil_r<-fil %>% filter_all(all_vars(!is.na(.)))

# adding time (3 year period)
all_comn <- unique(fil_r$conm)
time_data <- data.frame()
for (i in 1:length(unique(all_comn))){
  cur_comn <- subset(fil_r, conm==all_comn[i],select=c(current_ratio,
                                                       quick_ratio,
                                                       cash_ratio,
                                                       ocf_ratio,
                                                       debt_ratio,
                                                       de_ratio,
                                                       ic_ratio,
                                                       dsc_ratio,
                                                       at_ratio,
                                                       it_ratio,
                                                       gm_ratio,
                                                       om_ratio,
                                                       roa_ratio,
                                                       label
  ))
  if (dim(cur_comn)[1] >= 3){
    if (dim(time_data)[1] == 0){
      time_data <-  data.frame(t(unlist(cur_comn[1:3,])))
    }
    else{
      time_data <- rbind(time_data, data.frame(t(unlist(cur_comn[1:3,]))))
    }
  }
  if (dim(cur_comn)[1] >= 4){
    for(j in 2:(dim(cur_comn)[1]-2)){
      cur_data <- data.frame(t(unlist(cur_comn[j:(j+2),])))
      time_data <- rbind(time_data,cur_data)
    }
  }
}

# create model function
get_model <- function(input_data, num_layer, seleted_ratios){
  # split train, valid, and test
  random_index <- sample(dim(input_data)[1])
  num_train <- floor(0.7*dim(input_data)[1])
  train_index <- random_index[1:num_train]
  test_index <- random_index[num_train:dim(input_data)[1]]
  ratios_with_label <- c(seleted_ratios,'label3')
  col_list <- paste(seleted_ratios,collapse="+")
  col_list <- paste(c("label3~",col_list),collapse="")
  f <- formula(col_list)
  all_dt <- subset(input_data, select=ratios_with_label)
  # Training model
  train_dt <- all_dt[train_index,]
  nn=neuralnet(f,data=train_dt, hidden=num_layer, act.fct = "logistic",linear.output = FALSE, stepmax = 100000, threshold = 0.01)
  return(nn)
}

# Experiment model with different hidden layer number
all_comb <- combn(13,3)
best_model <- NULL
best_acc <- 0.5
l_ratios<-list()
l_time_data<-list()
for (i in 1:2){
  select_ratios <- c()
  for(j in 1:13){
    if (is.element(j,all_comb[,i])){
      select_ratios <- c(select_ratios, (colnames(time_data)[(3*j-2):(3*j)]))
    }
  }
  l_ratios[[i]]<-select_ratios
}

numCores <- detectCores() - 1
cl <- makeCluster(numCores)
clusterEvalQ(cl, 
             {
               library(lme4)
               library(neuralnet)
               })
parallel_results <- parLapply(cl, l_ratios, get_model,input_data=time_data, num_layer=c(6))
stopCluster(cl)

save(parallel_results, file="results.RData")
save(time_data,file = "time_data.RData")





