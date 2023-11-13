library(tidyverse)
library(ez)
library(psychReport)
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

table(dat$congruency, dat$transition)
########################
#      data prep       #
########################
# NOTE: Excluding incorrect trials and making sure only viable trials
# (repetition and switch) are considered in our analysis.
dat %<>% filter(corr == 1, transition %in% c("repetition", "switch"))

dat %>%
  group_by(congruency, transition) %>%
  summarise(meanRT = mean(rt))

# m.0 <- lm(rt ~ 1, dat)
# m.1 <- lm(rt ~ congruency, dat)
# m.2 <- lm(rt ~ congruency + task, dat)
# # m.3 <- lm(rt ~ congruency + task + (1 | vp_num), dat)
#
# anova(m.0, m.1, m.2, m.3)
