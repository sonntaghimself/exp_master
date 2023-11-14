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
  # vp_num == 3, practice == "False", transition %in% c("repetition", "switch")
  practice == "False", transition %in% c("repetition", "switch")
)

dat_blk <- dat %>%
  filter(congruency == "congruent") %>%
  group_by(blk) %>%
  summarise(rt_co = mean(rt))

dat_blk$rt_in <- dat %>%
  filter(congruency == "incongruent") %>%
  group_by(blk) %>%
  summarise(rt_in = mean(rt)) %>%
  select(rt_in)

dat_blk %<>% mutate(cong = rt_in - rt_co) %>% select(cong)
