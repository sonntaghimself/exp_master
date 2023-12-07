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
dat <- do.call(rbind, lapply(datFiles, read.table, header = TRUE, sep = ","))

dat %<>% filter(
  practice == "False", transition %in% c("repetition", "switch")
)

dat_corr <- dat %>% filter(corr == 1)
dat %>% head()
dat$rt <- dat$rt * 1000
################################################################################
#                                  Exclusion                                   #
################################################################################
dat %<>% filter(vp_num != 6 | blk <= 8)
dat %<>% na.omit()

dat$vp_num %<>% as.factor()
dat$congruency %<>% as.factor()
dat$transition %<>% as.factor()
dat$difficulty %<>% as.factor()

########################
#     global func      #
########################
CongBlock <- function(dat) {
  datBlk <- dat %>%
    group_by(blk, congruency) %>%
    summarize(
      rt = mean(rt[corr == 1]), # only correct trials
      er = mean(corr) * 100
    ) %>%
    pivot_wider(names_from = congruency, values_from = c(rt, er)) %>%
    mutate(
      rt_effect = rt_incongruent - rt_congruent,
      er_effect = er_congruent - er_incongruent
    )
  return(datBlk)
}
