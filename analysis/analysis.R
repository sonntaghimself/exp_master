library(tidyverse)
library(ez)
library(psychReport)
library(magrittr)

################################################################################
#                                only analysis                                 #
################################################################################
source(file = "./prep.R")

table(dat$congruency, dat$transition)

dat %<>% na.omit()

########################
#     descriptive      #
########################
CongBlock((dat %>% filter(task == "color" | difficulty == "easy")))
# # A tibble: 10 × 4
#      blk  rtCo rtIn$rtIn cong$rtIn
#    <int> <dbl>     <dbl>     <dbl>
#  1     3 0.821     0.895   0.0745
#  2     4 0.774     0.855   0.0804
#  3     5 0.769     0.824   0.0544
#  4     6 0.710     0.776   0.0661
#  5     7 0.743     0.747   0.00377
#  6     8 0.728     0.778   0.0500
#  7     9 0.671     0.682   0.0115
#  8    10 0.685     0.703   0.0173
#  9    11 0.693     0.712   0.0188
# 10    12 0.687     0.719   0.0322

CongBlock((dat %>% filter(task == "color" | difficulty == "hard")))
# # A tibble: 10 × 4
#      blk  rtCo rtIn$rtIn cong$rtIn
#    <int> <dbl>     <dbl>     <dbl>
#  1     3 0.958     0.997   0.0385
#  2     4 0.902     0.933   0.0315
#  3     5 0.886     0.909   0.0225
#  4     6 0.841     0.892   0.0509
#  5     7 0.803     0.838   0.0348
#  6     8 0.825     0.855   0.0297
#  7     9 0.766     0.768   0.00169
#  8    10 0.747     0.773   0.0255
#  9    11 0.760     0.784   0.0234
# 10    12 0.789     0.797   0.00871

CongBlock((dat %>% filter(task == "direction" | difficulty == "easy")))
# # A tibble: 10 × 4
#      blk  rtCo rtIn$rtIn cong$rtIn
#    <int> <dbl>     <dbl>     <dbl>
#  1     3 0.877     0.878  0.000687
#  2     4 0.824     0.845  0.0202
#  3     5 0.823     0.810 -0.0133
#  4     6 0.787     0.824  0.0366
#  5     7 0.766     0.778  0.0119
#  6     8 0.745     0.775  0.0299
#  7     9 0.692     0.713  0.0206
#  8    10 0.702     0.706  0.00420
#  9    11 0.706     0.744  0.0374
# 10    12 0.718     0.724  0.00627

CongBlock((dat %>% filter(task == "direction" | difficulty == "hard")))
# # A tibble: 10 × 4
#      blk  rtCo rtIn$rtIn cong$rtIn
#    <int> <dbl>     <dbl>     <dbl>
#  1     3 0.972     1.01    0.0340
#  2     4 0.906     0.916   0.00990
#  3     5 0.901     0.910   0.00982
#  4     6 0.845     0.880   0.0349
#  5     7 0.825     0.827   0.00117
#  6     8 0.830     0.852   0.0225
#  7     9 0.780     0.768  -0.0111
#  8    10 0.759     0.762   0.00305
#  9    11 0.790     0.771  -0.0188
# 10    12 0.780     0.778  -0.00179

dat %>%
  group_by(difficulty, task, congruency) %>%
  summarise(mean_corr = mean(rt))
#   difficulty task      congruency  mean_corr
#   <fct>      <chr>     <fct>           <dbl>
# 1 easy       color     congruent       0.647
# 2 easy       color     incongruent     0.714
# 3 easy       direction congruent       0.680
# 4 easy       direction incongruent     0.692
# 5 hard       color     congruent       0.872
# 6 hard       color     incongruent     0.923
# 7 hard       direction congruent       0.985
# 8 hard       direction incongruent     0.952

dat %>%
  group_by(difficulty, task, congruency) %>%
  summarise(mean_corr = mean(corr))
#   difficulty task      congruency  mean_corr
#   <fct>      <chr>     <fct>           <dbl>
# 1 easy       color     congruent       0.983
# 2 easy       color     incongruent     0.850
# 3 easy       direction congruent       0.995
# 4 easy       direction incongruent     0.949
# 5 hard       color     congruent       0.932
# 6 hard       color     incongruent     0.792
# 7 hard       direction congruent       0.877
# 8 hard       direction incongruent     0.813

################################################################################
#                                    Anovas                                    #
################################################################################
dat_aov <- dat %>%
  group_by(vp_num, congruency, transition, difficulty) %>%
  summarise(meanRT = mean(rt), meanER = mean(corr))

ez::ezANOVA(
  data = dat_aov, dv = meanRT, wid = vp_num, within = c(congruency, transition, difficulty)
)

ez::ezANOVA(
  data = dat_aov, dv = meanER, wid = vp_num, within = c(congruency, transition, difficulty)
)

# NOTE: this is the part where we got a psychReport Error message
dat_corr %<>%
  group_by(vp_num, congruency, difficulty, transition) %>%
  summarise(rt = mean(rt))

test_aov <- ez::ezANOVA(
  data = dat_corr, dv = rt,
  wid = vp_num, within = c(congruency, transition, difficulty),
  detailed = TRUE, return_aov = TRUE
)

psychReport::aovDispMeans(test_aov)

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
