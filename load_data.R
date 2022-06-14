# This script parses the json data [extracted from the Telegram channel]
# into the R environment

# Data consist of entries in the format
# {start: int, end: int, region: str}

# todo загроза артобстрілу


library("rjson")
library("tidyverse")

# Reversing so that the data is in the chronological order
raw_data <- rev(fromJSON(file = "data.json"))

# active sirens
active_sirens <- list()

all_sirens <- list()

for(el in raw_data) {
  region <- str_split_fixed(el["message"], "#", 2)[2]
  if (region == ""){
    next
  }
  
  time <- el[["date"]]
  
  message_type_raw <- substr(el["message"], 1, 1)
  
  # if red circle
  if (message_type_raw == "🔴"){
    # THE SIREN STARTED
    active_entry = list(list(time=time, region=region))
    active_sirens <- c(active_sirens, active_entry)
  }
  
  # if green or yellow
  if(message_type_raw == "🟢" || message_type_raw == "🟡"){
    # THE SIREN ENDED
    i <- 1
    for(active in active_sirens){
      if(active["region"] == region){
        # Add the siren to the data set
        
        siren_entry = list(list(start=active[["time"]], end=time, region=region))
        all_sirens <- c(all_sirens, siren_entry)
        
        active_sirens[i] <- NULL
        
        break
      }
      i <- i+1
    }
    
  }
  
 rm(active)
 rm(active_entry)
 rm(el)
 rm(raw_data)
 rm(siren_entry)
 
 rm(i)
 rm(message_type_raw)
 rm(region)
 rm(time)
 
}
