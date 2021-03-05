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

postcodes <- unique(d$perm_res_postcode)
post1 <- postcodes[1:400]
post2 <- postcodes[401:800]
post3 <- postcodes[801:1200]
post4 <- postcodes[1201:1600]
post5 <- postcodes[1601:2000]
post6 <- postcodes[2001:2400]
post7 <- postcodes[2401:2653]

calculate_features <- function(post_set = post1){
  
  storage <- list()
  
  for(p in post_set){
    
    message(paste0("Analysing postcode: ", p))
    
    tsPrep <- d %>%
      filter(perm_res_postcode == p) %>%
      arrange(year)
    
    tsData <- tsPrep$eftsl
    
    tmp <- catch22_all(tsData) %>%
      mutate(perm_res_postcode = p)
    
    storage[[p]] <- tmp
  }
  
  outs <- rbindlist(storage, use.names = TRUE)
  return(outs)
}

calc_1 <- calculate_features(post_set = post1)
save(calc_1, file = "data/calc_1.Rda")
calc_2 <- calculate_features(post_set = post2)
save(calc_2, file = "data/calc_2.Rda")
calc_3 <- calculate_features(post_set = post3)
save(calc_3, file = "data/calc_3.Rda")
calc_4 <- calculate_features(post_set = post4)
save(calc_4, file = "data/calc_4.Rda")
calc_5 <- calculate_features(post_set = post5)
save(calc_5, file = "data/calc_5.Rda")
calc_6 <- calculate_features(post_set = post6)
save(calc_6, file = "data/calc_6.Rda")
calc_7 <- calculate_features(post_set = post7)
save(calc_7, file = "data/calc_7.Rda")

# Bind all together

load("data/calc_1.Rda")
load("data/calc_2.Rda")
load("data/calc_3.Rda")
load("data/calc_4.Rda")
load("data/calc_5.Rda")
load("data/calc_6.Rda")
load("data/calc_7.Rda")

outs <- bind_rows(calc_1, calc_2, calc_3, calc_4, calc_5, calc_6, calc_7) %>%
  rename(perm_res_postcode = postcode)

#---------------- Join back regions ----------------------

regions <- d %>%
  dplyr::select(c(perm_res_postcode, ra_name_2016))

outs <- outs %>%
  inner_join(regions, by = c("perm_res_postcode" = "perm_res_postcode"))

save(outs, file = "data/computed-features.Rda")
