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
CongBlock((dat %>% filter(task == "color" & difficulty == "easy")))
CongBlock((dat %>% filter(task == "color" & difficulty == "hard")))
CongBlock((dat %>% filter(task == "direction" & difficulty == "easy")))
CongBlock((dat %>% filter(task == "direction" & difficulty == "hard")))

dat_agg_vp <- dat %>%
  group_by(vp_num, difficulty, transition, congruency) %>%
  summarise(
    mean_rt = mean(rt),
    mean_er = mean(corr) * 100
  )

dat_agg <- dat_agg_vp %>%
  group_by(difficulty, transition, congruency) %>%
  summarise(
    mean_rt = mean(mean_rt),
    mean_er = mean(mean_er)
  )

################################################################################
#                                    Anovas                                    #
################################################################################
aov_rt <- ez::ezANOVA(
  data = dat_agg_vp, dv = mean_rt, wid = vp_num, within = c(congruency, transition, difficulty),
  detailed = TRUE, return_aov = TRUE
)
aov_rt <- aovTable(aov_rt) # simplified table output
aovDispMeans(aov_rt) # then this runs

aov_er <- ez::ezANOVA(
  data = dat_agg_vp, dv = mean_er, wid = vp_num, within = c(congruency, transition, difficulty),
  detailed = TRUE, return_aov = TRUE
)
aov_er <- aovTable(aov_er) # simplified table output
aovDispMeans(aov_er) # then this runs
