library(tidyverse)
library(ez)
library(psychReport)
library(magrittr)

library(DMCfun)
library(dplyr)

#### *************** IMPORTANT ********************
### YOU NEED TO INSTALL THE NEWEST DMCFUN VERSION FROM GITHUB (otherwise some part of the delta plots might not run)
####
# install version from  GitHub
# install.packages("devtools")
#devtools::install_github("igmmgi/DMCfun")

###############################################################################
#                             reading in the Data                             #
###############################################################################
datDir <- ("./Results")
datFiles <- list.files( path = datDir, full.names = TRUE )
dat <- do.call(rbind, lapply(datFiles, read.table, header = TRUE, sep = ","))

dat %<>% filter(
  practice == "False", transition %in% c("repetition", "switch")
)

# names(dat)
# table(dat$vp_num)  # why fewer trials in vp 7?
# table(dat$vp_num, dat$blk)
# table(dat$congruency)
# table(dat$task)
# table(dat$congruency, dat$task)
# table(dat$transition, dat$congruency, dat$task)

# dat_corr <- dat %>% filter(corr == 1) # usually want to also analyse error rates?

hist(dat$rt, 100)

# might be easier working in ms later
dat$rt <- dat$rt * 1000
table(dat$corr) # 2 probably too slow

# use later to exclude badvp6 after block 8
dat$badVP6 <-ifelse(dat$vp_num==6&dat$blk>8,"bad","good")

#####NEWVICTOR####
datAggVP <- dat %>%
  filter(blk > 2,corr %in% c(0,1)) %>%
  filter(badVP6!="bad") %>%
  filter(rt>150,rt<3000)%>%
  #filter(vp_num!=6&blk>8)%>% # exclude blk > 8 for VP 6 because I think this was the one who struggled with the task
  group_by(vp_num, task,transition,difficulty,congruency) %>%
  summarize(nTotal    = n(),
            rt   = mean(rt[corr == 1]),
            error = (sum(corr == 0) / nTotal) * 100)

datAggVP$vp_num  <- factor(datAggVP$vp_num)
datAggVP$task <- factor(datAggVP$task)
datAggVP$transition <- factor(datAggVP$transition)
datAggVP$difficulty <- factor(datAggVP$difficulty)
datAggVP$congruency <- factor(datAggVP$congruency)

aov_RT <- aov(rt ~ congruency*transition*difficulty*task + Error(vp_num/(task*transition*difficulty*task)), datAggVP)
aov_RT <- aovTable(aov_RT)
aovDispMeans(aov_RT)

aov_RT <- aov(error ~ congruency*transition*difficulty*task + Error(vp_num/(task*transition*difficulty*task)), datAggVP)
aov_RT <- aovTable(aov_RT)
aovDispMeans(aov_RT)

#separately for each task: color
aov_RT <- aov(rt ~ congruency*transition*difficulty + Error(vp_num/(congruency*transition*difficulty)), datAggVP[datAggVP$task=="color",])
aov_RT <- aovTable(aov_RT)
aovDispMeans(aov_RT)

aov_ER <- aov(error ~ congruency*transition*difficulty + Error(vp_num/(congruency*transition*difficulty)), datAggVP[datAggVP$task=="color",])
aov_ER <- aovTable(aov_ER)
aovDispMeans(aov_ER)

#separately for each task: direction
aov_RT <- aov(rt ~ congruency*transition*difficulty + Error(vp_num/(congruency*transition*difficulty)), datAggVP[datAggVP$task=="direction",])
aov_RT <- aovTable(aov_RT)
aovDispMeans(aov_RT)

aov_ER <- aov(error ~ congruency*transition*difficulty + Error(vp_num/(congruency*transition*difficulty)), datAggVP[datAggVP$task=="direction",])
aov_ER <- aovTable(aov_ER)
aovDispMeans(aov_ER)

##################################################
# Initial Delta plots using DMCfun for Color Task #
##################################################
dat_Col_Rep_Easy <- dat %>%
  filter(blk > 2,corr %in% c(0,1)) %>%
  filter(rt>150,rt<3000)%>%
  filter(badVP6!="bad") %>%
  filter(task=="color",transition=="repetition",difficulty == "easy")%>%
  dmcObservedData(., nDelta = 4, outlier = c(150, 3000),
                  columns = c("vp_num", "congruency", "rt", "corr"),
                  compCoding = c("congruent", "incongruent"),
                  errorCoding = c(1, 0))
plot(dat_Col_Rep_Easy)

dat_Col_Rep_Hard <- dat %>%
  filter(blk > 2,corr %in% c(0,1)) %>%
  filter(rt>150,rt<3000)%>%
  filter(badVP6!="bad") %>%
  filter(task=="color",transition=="repetition",difficulty == "hard")%>%
  dmcObservedData(., nDelta = 4, outlier = c(150, 3000),
                  columns = c("vp_num", "congruency", "rt", "corr"),
                  compCoding = c("congruent", "incongruent"),
                  errorCoding = c(1, 0))
plot(dat_Col_Rep_Hard)

dat_Col_Switch_Easy <- dat %>%
  filter(blk > 2,corr %in% c(0,1)) %>%
  filter(rt>150,rt<3000)%>%
  filter(badVP6!="bad") %>%
  filter(task=="color",transition=="switch",difficulty == "easy")%>%
  dmcObservedData(., nDelta = 4, outlier = c(150, 3000),
                  columns = c("vp_num", "congruency", "rt", "corr"),
                  compCoding = c("congruent", "incongruent"),
                  errorCoding = c(1, 0))
plot(dat_Col_Switch_Easy)

dat_Col_Switch_Hard <- dat %>%
  filter(blk > 2,corr %in% c(0,1)) %>%
  filter(rt>150,rt<3000)%>%
  filter(badVP6!="bad") %>%
  filter(task=="color",transition=="switch",difficulty == "hard")%>%
  dmcObservedData(., nDelta = 4, outlier = c(150, 3000),
                  columns = c("vp_num", "congruency", "rt", "corr"),
                  compCoding = c("congruent", "incongruent"),
                  errorCoding = c(1, 0))
plot(dat_Col_Switch_Hard)

dat_dmc<- dmcCombineObservedData(dat_Col_Rep_Easy,dat_Col_Rep_Hard,dat_Col_Switch_Easy,dat_Col_Switch_Hard)
dat_dmc_rep <- dmcCombineObservedData(dat_Col_Rep_Easy,dat_Col_Rep_Hard) 
dat_dmc_switch <- dmcCombineObservedData(dat_Col_Switch_Easy,dat_Col_Switch_Hard) 

# all on the same plot
dev.off()
plot(dat_dmc, figType = "delta", xlimDelta = c(400, 1100), ylimDelta = c(0, 150), 
     cols = c("black", "grey", "black", "grey"), lty = c(1,1,2,2), pch = c(1,1,2,2), legend = FALSE, resetPar = FALSE)
legend(400, 150, legend = c("Rep-Easy", "Rep-Hard", "Switch-Easy", "Switch-Hard"), 
       col = c("black", "grey", "black", "grey"), lty = c(1, 1, 2, 2), pch = c(1,1,2,2))

# separate plots
#par(mfrow = c(1,2)) 
#plot(dat_dmc_rep, figType = "delta", xlimDelta = c(400, 1200), ylimDelta = c(0, 200), cols = c("black", "grey"), resetPar = FALSE, main = "Rep")
#legend(400, 190, legend = c("-Rep-Easy", "Rep-Hard"), col = c("black", "grey"), lty = c(1,1), pch = c(1,1))
#plot(dat_dmc_switch, figType = "delta", xlimDelta = c(400, 1200), ylimDelta = c(0, 200), cols = c("black", "grey"), resetPar = FALSE, main = "Switch")
#legend(400, 190, legend = c("Switch-Easy", "Switch-Hard"), col = c("black", "grey"), lty = c(1,1), pch = c(1,1))

##################################################
# Initial Delta plots using DMCfun for Direction Task #
##################################################
#?dmcObservedData
dat_Dir_Rep_Easy <- dat %>%
  filter(blk > 2,corr %in% c(0,1)) %>%
  filter(rt>150,rt<3000)%>%
  filter(vp_num==6) %>%
  #filter(badVP6!="bad") %>%
  filter(task=="direction",transition=="repetition",difficulty == "easy") %>%
  dmcObservedData(., nDelta = 4, outlier = c(150, 3000),
                  columns = c("vp_num", "congruency", "rt", "corr"),
                  compCoding = c("congruent", "incongruent"),
                  errorCoding = c(1, 0))
plot(dat_Dir_Rep_Easy)


dat_Dir_Rep_Hard <- dat %>%
  filter(blk > 2,corr %in% c(0,1)) %>%
  filter(rt>150,rt<3000)%>%
  filter(badVP6!="bad") %>%
  filter(task=="direction",transition=="repetition",difficulty == "hard")%>%
  dmcObservedData(., nDelta = 4, outlier = c(150, 3000),
                  columns = c("vp_num", "congruency", "rt", "corr"),
                  compCoding = c("congruent", "incongruent"),
                  errorCoding = c(1, 0))
plot(dat_Dir_Rep_Hard)

dat_Dir_Switch_Easy <- dat %>%
  filter(blk > 2,corr %in% c(0,1)) %>%
  filter(rt>150,rt<3000)%>%
  filter(badVP6!="bad") %>%
  filter(task=="direction",transition=="switch",difficulty == "easy")%>%
  dmcObservedData(., nDelta = 4, outlier = c(150, 3000),
                  columns = c("vp_num", "congruency", "rt", "corr"),
                  compCoding = c("congruent", "incongruent"),
                  errorCoding = c(1, 0))
plot(dat_Dir_Switch_Easy)

dat_Dir_Switch_Hard <- dat %>%
  filter(blk > 2,corr %in% c(0,1)) %>%
  filter(rt>150,rt<3000)%>%
  filter(badVP6!="bad") %>%
  filter(task=="direction",transition=="switch",difficulty == "hard")%>%
  dmcObservedData(., nDelta = 4, outlier = c(150, 3000),
                  columns = c("vp_num", "congruency", "rt", "corr"),
                  compCoding = c("congruent", "incongruent"),
                  errorCoding = c(1, 0))
plot(dat_Dir_Switch_Hard)

dat_dmc<- dmcCombineObservedData(dat_Dir_Rep_Easy,dat_Dir_Rep_Hard,dat_Dir_Switch_Easy,dat_Dir_Switch_Hard)
dat_dmc_rep <- dmcCombineObservedData(dat_Dir_Rep_Easy,dat_Dir_Rep_Hard) 
dat_dmc_switch <- dmcCombineObservedData(dat_Dir_Switch_Easy,dat_Dir_Switch_Hard) 

# all on the same plot
dev.off()
plot(dat_dmc, figType = "delta", xlimDelta = c(500, 1100), ylimDelta = c(-80, 50), 
     cols = c("black", "grey", "black", "grey"), lty = c(1,1,2,2), pch = c(1,1,2,2), legend = FALSE, resetPar = FALSE)
legend(500, -50, legend = c("Rep-Easy", "Rep-Hard", "Switch-Easy", "Switch-Hard"), 
       col = c("black", "grey", "black", "grey"), lty = c(1, 1, 2, 2), pch = c(1,1,2,2))

# separate plots
#par(mfrow = c(1,2)) 
#plot(dat_dmc_rep, figType = "delta", xlimDelta = c(400, 1200), ylimDelta = c(0, 200), cols = c("black", "grey"), resetPar = FALSE, main = "Rep")
#legend(400, 190, legend = c("-Rep-Easy", "Rep-Hard"), col = c("black", "grey"), lty = c(1,1), pch = c(1,1))
#plot(dat_dmc_switch, figType = "delta", xlimDelta = c(400, 1200), ylimDelta = c(0, 200), cols = c("black", "grey"), resetPar = FALSE, main = "Switch")
#legend(400, 190, legend = c("Switch-Easy", "Switch-Hard"), col = c("black", "grey"), lty = c(1,1), pch = c(1,1))
