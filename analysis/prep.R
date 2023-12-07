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

dat$vp_num %<>% as.factor()
dat$congruency %<>% as.factor()
dat$transition %<>% as.factor()
dat$difficulty %<>% as.factor()

########################
#     global func      #
########################
CongBlock <- function(dat) {
  datBlk <- dat %>%
    filter(congruency == "congruent") %>%
    group_by(blk) %>%
    summarise(rtCo = mean(rt))
  datBlk$rtIn <- dat %>%
    filter(congruency == "incongruent") %>%
    group_by(blk) %>%
    summarise(rtIn = mean(rt)) %>%
    select(rtIn)
  datBlk %<>% mutate(cong = rtIn - rtCo)
  return(datBlk)
}
