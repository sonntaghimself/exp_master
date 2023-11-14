library(tidyverse)
library(ez)
library(psychReport)
library(magrittr)

################################################################################
#                                only analysis                                 #
################################################################################
source(file = "./prep.R")

table(dat$congruency, dat$transition)

dat %>%
  group_by(blk, congruency) %>%
  summarise(mean_RT = mean(rt))


ez::ezANOVA(
  data = dat, dv = rt, wid = vp_num, within = c(congruency, transition)
)

########################
#   random analyses    #
########################
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
