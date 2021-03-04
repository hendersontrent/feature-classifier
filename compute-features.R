#----------------------------------------
# This script sets out to produce highly
# comparative time-series analysis of
# domestic student data by postcode
#----------------------------------------

#--------------------------------------
# Author: Trent Henderson, 4 March 2021
#--------------------------------------

d <- read_csv("data/ts.csv")

#---------------- Run catch22 ----------------------------

storage <- list()
postcodes <- unique(d$perm_res_postcode)

for(p in postcodes){
  
  message(paste0("Analysing postcode: ", p))
  
  tsPrep <- d %>%
    filter(perm_res_postcode == p) %>%
    arrange(year)
  
  tsData <- tsPrep$eftsl
  
  tmp <- catch22_all(tsData) %>%
    mutate(postcode = p)
  
  storage[[p]] <- tmp
}

outs <- rbindlist(storage, use.names = TRUE)

#---------------- Join back regions ----------------------

regions <- d %>%
  dplyr::select(c(perm_res_postcode, ra_name_2016))

outs <- outs %>%
  inner_join(regions, by = c("perm_res_postcode" = "perm_res_postcode"))
