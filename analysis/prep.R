library(tidyverse)
library(magrittr)

###############################################################################
#                             reading in the Data                             #
###############################################################################
datDir <- ("../Results")
datFiles <- list.files(
  path = datDir,
  full.names = TRUE
)

dat <- NULL
for (f in datFiles) {
  dat <- rbind(dat, read.table(f, header = TRUE, sep = ","))
}

dat %<>% filter(
  practice == "False", transition %in% c("repetition", "switch")
)

dat_corr <- dat %>% filter(corr == 1)

dat %>% head()

################################################################################
#                                  Exclusion                                   #
################################################################################
dat %<>% filter(vp_num != 6 | blk <= 8)

dat %<>% na.omit()

dat_blk <- dat %>%
  filter(congruency == "congruent") %>%
  group_by(blk) %>%
  summarise(rt_co = mean(rt))

dat_blk$rt_in <- dat %>%
  filter(congruency == "incongruent") %>%
  group_by(blk) %>%
  summarise(rt_in = mean(rt)) %>%
  select(rt_in)

dat_blk %<>% mutate(cong = rt_in - rt_co)

dat_blk
# # A tibble: 10 × 4
#      blk rt_co rt_in$rt_in cong$rt_in
#    <int> <dbl>       <dbl>      <dbl>
#  1     3 0.907       0.944    0.0369
#  2     4 0.852       0.887    0.0355
#  3     5 0.845       0.863    0.0184
#  4     6 0.796       0.843    0.0471
#  5     7 0.784       0.797    0.0129
#  6     8 0.782       0.815    0.0330
#  7     9 0.727       0.733    0.00568
#  8    10 0.723       0.736    0.0125
#  9    11 0.737       0.753    0.0152
# 10    12 0.743       0.755    0.0114
