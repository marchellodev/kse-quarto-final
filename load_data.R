# This script parses the json data [extracted from the Telegram channel]
# into the R environment

# Data consist of entries in the format
# {start: int, end: int, region: str}

library("rjson")
library("tidyverse")

# Reversing so that the arr is in the chronological order
raw_data <- rev(fromJSON(file = "data.json"))


for(el in raw_data) {
  region <- str_split_fixed(el["message"], "#", 2)[,2]
  if (region == ""){
    next
  }
  
  print(region)
}
