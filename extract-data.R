#------------------------------------------------
# This script sets out to pull some time series
# data at the postcode level in terms of EFTSL
# flows
#------------------------------------------------

#--------------------------------------
# Author: Trent Henderson, 4 March 2021
#--------------------------------------

library(nousutils)
library(DBI)

#--------------------------- Pull data -----------------------------

sql <- "
SELECT
sum(eftsl) AS eftsl,
year,
perm_res_postcode,
ra_name_2016
FROM higher_ed.v_equity_consolidated AS a
LEFT JOIN common.d_postcodes AS b
ON a.perm_res_postcode = b.postcode
WHERE citizen_or_residence = 'Domestic'
AND commencing_status = 'Commencing students'
GROUP BY year, perm_res_postcode, ra_name_2016
ORDER BY year DESC, eftsl DESC
"

d <- dbGetQuery(dawn, sql) %>%
  mutate(ra_name_2016 = ifelse(ra_name_2016 == "Major Cities of Australia", "Major Cities of Australia", "Not Major Cities")) %>%
  drop_na()

#--------------------------- High level data visualisation ---------

d %>%
  ggplot(aes(x = year, y = eftsl)) +
  geom_line(aes(group = perm_res_postcode), colour = "steelblue2") +
  labs(x = "Year",
       y = "EFTSL") +
  scale_x_continuous(limits = c(min(d$year), max(d$year)),
                     breaks = seq(from = min(d$year), to = max(d$year), by = 1)) +
  scale_y_continuous(labels = comma) +
  facet_wrap(~ra_name_2016, dir = "v") +
  theme_bw() +
  theme(panel.grid.minor = element_blank())

#--------------------------- Export data ---------------------------

write_csv(d, "data/ts.csv")
