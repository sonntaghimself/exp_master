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
################################################################################
#                              congruency effect                               #
################################################################################
dat %>%
  group_by(blk, congruency) %>%
  summarise(mean_RT = mean(rt))

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
# # A tibble: 10 × 4
#      blk rt_co rt_in$rt_in cong$rt_in
#    <int> <dbl>       <dbl>      <dbl>
#  1     3 0.747       0.800    0.0524
#  2     4 0.620       0.653    0.0325
#  3     5 0.601       0.708    0.106
#  4     6 0.613       0.832    0.219
#  5     7 0.734       0.722   -0.0124
#  6     8 0.569       0.605    0.0365
#  7     9 0.580       0.612    0.0318
#  8    10 0.614       0.607   -0.00747
#  9    11 0.634       0.745    0.111
# 10    12 0.701       0.664   -0.0370

ez::ezANOVA(
  data = dat, dv = rt, wid = vp_num, within = c(congruency, transition)
)

########################
#   random analyses    #
########################
m.0() <- lm(rt ~ 1, dat)
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
