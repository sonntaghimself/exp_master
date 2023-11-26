library(tidyverse)
library(magrittr)
library(DMCfun)

########################
#         prep         #
########################
source(file = "./prep.R")
dat$rt <- dat$rt * 1000

################################################################################
#                                   Figure 1                                   #
################################################################################
### DMC simulation. This simulation involved 100,000 trials for each compatibility condition with the following default simulation parameters: amp = 20, tau = 30, drc = 0.5, bnds = 75, resMean = 300, resSD = 30, aaShape = 2.

### NOTE: honestly, I may have misunderstood the task?
dmc <- dmcSim(fullData = TRUE)
plot(dmc, cex.lab = 1.2, cex.axis = 1.2, mgp = c(2.5, 1, 0))

################################################################################
#                                   Figure 2                                   #
################################################################################
###
dmc <- dmcSims(list(tau = seq(20, 170, 10)))
plot(dmc, col = c("red", "green"), ncol = 2)

################################################################################
#                                   Figure 3                                   #
################################################################################
r_num <- 1:nrow(flankerData$data)
flank <- cbind(r_num, flankerData$data)
to_exclude <- flank %>%
  filter(Error == 1) %>%
  select(r_num)
flank %<>% filter(Error == 0, !(r_num %in% (to_exclude + 1)))
flank <- dmcObservedData(flank, nDelta = 9)
fit <- dmcFit(flank, nDelta = 9) # flanker data from Ulrich et al. (2015)
plot(fit, flank)
summary(fit)

################################################################################
#                                   Figure 4                                   #
################################################################################
r_num <- 1:nrow(simonData$data)
simon <- cbind(r_num, simonData$data)
to_exclude <- simon %>%
  filter(Error == 1) %>%
  select(r_num)
simon %<>% filter(Error == 0, !(r_num %in% (to_exclude + 1)))
simon <- dmcObservedData(flank, nDelta = 9)
fit <- dmcFit(simon, nDelta = 9) # simon data from Ulrich et al. (2015)
plot(fit, simon)
summary(fit)

################################################################################
#                                     DMC                                      #
################################################################################
# dat %>% head()
# dat[dat$transition == "switch", ] %>% head()

delta_switch <- DMCfun::dmcObservedData(
  dat[dat$transition == "switch", ],
  outlier = c(200, 2000),
  nDelta = 9,
  columns = c("transition", "congruency", "rt", "corr"),
  compCoding = c("congruent", "incongruent"),
  errorCoding = c(1, 0)
)

# delta_switch %>% plot(figType = "delta")

delta_repeat <- DMCfun::dmcObservedData(
  dat[dat$transition == "repetition", ],
  outlier = c(200, 2000),
  nDelta = 9,
  columns = c("transition", "congruency", "rt", "corr"),
  compCoding = c("congruent", "incongruent"),
  errorCoding = c(1, 0)
)

# delta_repeat %>% plot(figType = "delta")

delta_combined <- DMCfun::dmcCombineObservedData(delta_switch, delta_repeat)

plot(delta_combined,
  figType = "delta", cols = c("black", "grey"),
  xlimDelta = c(300, 1300), ylimDelta = c(-20, 150),
  resetPar = FALSE, ylabs = FALSE, legend = FALSE
)

title(main = "Delta Plots", ylab = "Conflict Effect [ms]")
legend(300, 150, legend = c("Switch", "Repeat"), col = c("black", "grey"), lty = 1)
