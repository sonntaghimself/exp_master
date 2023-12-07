library(tidyverse)
library(ez)
library(psychReport)
library(magrittr)

########################
#     global func      #
########################
CongBlock <- function(dat) {
  datBlk <- dat %>%
    filter(congruency == "congruent") %>%
    group_by(blk) %>%
    summarise(rtCo = mean(rt))
  datBlk$rtIn <- datEasy %>%
    filter(congruency == "incongruent") %>%
    group_by(blk) %>%
    summarise(rtIn = mean(rt)) %>%
    select(rtIn)
  datBlk %<>% mutate(cong = rtIn - rtCo)
  return(datBlk)
}

################################################################################
#                                only analysis                                 #
################################################################################
source(file = "./prep.R")

table(dat$congruency, dat$transition)

# dat %<>% filter(blk >= 8)
# dat %>% summarise(mean_RT = mean(rt))

dat %<>% na.omit()

dat %>%
  # filter(vp_num == 6) %>%
  group_by(difficulty, transition, congruency) %>%
  summarise(mean_corr = mean(corr))

ez::ezANOVA(
  data = dat, dv = corr, wid = vp_num, within = c(congruency, transition, difficulty)
)

datEasy <- dat %>% filter(difficulty == "easy")

CongBlock(dat)
CongBlock(datEasy)

# for (vpNum in c(6:10)) {
#   print(vpNum)
#   CongBlock(datEasy %>% filter(vp_num == vpNum))
# }

dat_blk <- datEasy %>%
  filter(congruency == "congruent") %>%
  group_by(blk) %>%
  summarise(rt_co = mean(rt))

dat_blk$rt_in <- datEasy %>%
  filter(congruency == "incongruent") %>%
  group_by(blk) %>%
  summarise(rt_in = mean(rt)) %>%
  select(rt_in)

dat_blk %<>% mutate(cong = rt_in - rt_co)
dat_blk
# A tibble: 10 × 4
#      blk rt_co rt_in$rt_in cong$rt_in
#    <int> <dbl>       <dbl>      <dbl>
#  1     3 0.733       0.771    0.0389
#  2     4 0.695       0.774    0.0799
#  3     5 0.699       0.724    0.0249
#  4     6 0.654       0.714    0.0599
#  5     7 0.695       0.692   -0.00233
#  6     8 0.645       0.699    0.0538
#  7     9 0.590       0.627    0.0368
#  8    10 0.634       0.641    0.00722
#  9    11 0.624       0.678    0.0539
# 10    12 0.620       0.655    0.0350

ez::ezANOVA(
  data = datEasy, dv = rt, wid = vp_num, within = c(congruency, transition)
)

dat_corr %<>%
  group_by(vp_num, congruency, difficulty, transition) %>%
  summarise(rt = mean(rt))

test_aov <- ez::ezANOVA(
  data = dat_corr, dv = rt,
  wid = vp_num, within = c(congruency, transition, difficulty),
  detailed = TRUE, return_aov = TRUE
)

psychReport::aovDispMeans(test_aov)

# old design:
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
m.2 <- lm(rt ~ congruency + difficulty, dat)
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
