library(tidyverse)
library(magrittr)
library(DMCfun)

########################
#         prep         #
########################
source(file = "./prep.R")

################################################################################
#                                     DMC                                      #
################################################################################
dat %>% head()
# dat[dat$transition == "switch", ] %>% head()

dat$rt <- dat$rt * 1000

delta_switch <- DMCfun::dmcObservedData(
  dat[dat$transition == "switch", ],
  outlier = c(200, 2000),
  nDelta = 3,
  columns = c("transition", "congruency", "rt", "corr"),
  compCoding = c("congruent", "incongruent"),
  errorCoding = c(1, 0)
)

delta_switch %>% plot(figType = "delta")

delta_repeat <- DMCfun::dmcObservedData(
  dat[dat$transition == "repetition", ],
  outlier = c(200, 2000),
  nDelta = 3,
  columns = c("transition", "congruency", "rt", "corr"),
  compCoding = c("congruent", "incongruent"),
  errorCoding = c(1, 0)
)

delta_repeat %>% plot(figType = "delta")

delta_combined <- DMCfun::dmcCombineObservedData(delta_switch, delta_repeat)

plot(delta_combined,
  figType = "delta", cols = c("black", "grey"),
  xlimDelta = c(300, 800), ylimDelta = c(-20, 60),
  resetPar = FALSE, ylabs = FALSE, legend = FALSE
)

title(main = "Delta Plots", ylab = "Conflict Effect [ms]")
legend(300, 60, legend = c("Switch", "Repeat"), col = c("black", "grey"), lty = 1)
