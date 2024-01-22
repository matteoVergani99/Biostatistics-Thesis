rm(list=ls())
library(LMest)
data("RLMSlong") # formato long
data("RLMSdat") # formato wide
library(tidyr)
RLMSlong$id <- factor(RLMSlong$id)
data_long <- gather(RLMSdat,
                    key="rlms",
                    value="value",
                    IKSJQ:IKSJW,
                    factor_key = TRUE)
require(reshape2)
attach(RLMSdat)
id <- 1:nrow(RLMSdat)
data_long <- melt(RLMSdat,
                  measure.vars = c("IKSJQ","IKSJR","IKSJS","IKSJT","IKSJU","IKSJV","IKSJW"),
                  variable.name = "condition",
                  value.name = "misura")
data_long <- cbind(id,data_long)
time <- rep(0,length(data_long$condition))
for(i in 1:length(data_long$condition)){
  if(data_long[i,"condition"]=="IKSJQ"){
    time[i]=1
    }
  else if(data_long[i,"condition"]=="IKSJR"){
    time[i]=2
  }
  else if(data_long[i,"condition"]=="IKSJS"){
    time[i]=3
  }
  else if(data_long[i,"condition"]=="IKSJT"){
    time[i]=4
  }
  else if(data_long[i,"condition"]=="IKSJU"){
    time[i]=5
  }
  else if(data_long[i,"condition"]=="IKSJV"){
    time[i]=6
  }
  else if(data_long[i,"condition"]=="IKSJW"){
    time[i]=7
  }
}
data_long <- cbind(time,data_long)
