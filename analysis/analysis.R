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

dat %<>% filter(vp_num == 1, practice == "False")
table(dat$congruency, dat$transition)
########################
#      data prep       #
########################
# NOTE: Excluding incorrect trials and making sure only viable trials
# (repetition and switch) are considered in our analysis.
dat %<>% filter(corr == 1, transition %in% c("repetition", "switch"))

dat$rt %>% range()

dat %>%
  group_by(congruency, transition) %>%
  summarise(meanRT = mean(rt))

m.0 <- lm(rt ~ 1, dat)
m.1 <- lm(rt ~ congruency, dat)
m.2 <- lm(rt ~ congruency + transition, dat)
m.3 <- lm(rt ~ congruency * transition, dat)
# m.3 <- lm(rt ~ congruency + task + (1 | vp_num), dat)

# anova(m.0, m.1, m.2)
anova(m.0, m.1, m.2, m.3)
# Analysis of Variance Table
#
# Model 1: rt ~ 1
# Model 2: rt ~ congruency
# Model 3: rt ~ congruency + transition
# Model 4: rt ~ congruency * transition
#   Res.Df    RSS Df Sum of Sq       F    Pr(>F)
# 1    596 37.299
# 2    595 36.935  1   0.36428  5.9802 0.0147575 *
# 3    594 36.123  1   0.81175 13.3258 0.0002849 ***
# 4    593 36.123  1   0.00043  0.0070 0.9331754
# ---
# Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
