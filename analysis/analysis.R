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

ez::ezANOVA(
  data = dat_corr, dv = rt,
  wid = vp_num, within = c(congruency, transition),
  detailed = TRUE, return_aov = TRUE
) %>% psychReport::aovDispTable()

# ════════════════════════════════════════════ ANOVA:. ════════════════════════════════════════════
#                 Effect DFn DFd          SSn          SSd         F           p p<.05         ges
#            (Intercept)   1   4 7.3595303526 0.3992842446 73.727230 0.001010674     * 0.946716545
#             congruency   1   4 0.0259206804 0.0122296735  8.477963 0.043604154     * 0.058892900
#             transition   1   4 0.0108401172 0.0020583437 21.065708 0.010108812     * 0.025503040
#  congruency:transition   1   4 0.0008497399 0.0006395772  5.314385 0.082457508       0.002047262
# ─────────────────────────────────────────────────────────────────────────────────────────────────

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
# 1   3599 427.13
# 2   3598 423.53  1    3.5993 30.6725 3.274e-08 ***
# 3   3597 422.09  1    1.4414 12.2828 0.0004627 ***
# 4   3596 421.98  1    0.1098  0.9357 0.3334582
