source(file = "./analysis.R")

################################################################################
#                                   Graphics                                   #
################################################################################
########################
#        Spende        #
########################
dat_graph <- aggregate(rt ~ congruency + transition, dat, mean)
#    congruency transition        rt
# 1   congruent repetition 0.3123476
# 2 incongruent repetition 0.4657383
# 3   congruent     switch 0.5667802
# 4 incongruent     switch 0.3962618

dat_graph$congruency <- as.factor(dat_graph$congruency)
dat_graph$transition <- as.factor(dat_graph$transition)

pdf("./graphics/congruency_transition.pdf", height = 5, width = 5, pointsize = 10)

bplot <- barplot(dat_graph$rt,
  xlab = "Transition Type", ylab = "RT",
  col = c("#CCCCCC", "#6699FF"), beside = TRUE, ylim = c(0, 1), xpd = FALSE
)

axis(side = 1, at = seq(0, 5), labels = FALSE, lwd.ticks = NA)
axis(side = 1, at = 1.3, expression(Repetition))
axis(side = 1, at = 3.7, expression(Switch))
axis(side = 1, at = 2.5, labels = FALSE, tck = -.1)


legend(0.5, 0.8, expression(Congruent, incongruent),
  pch = c(21, 21),
  title = "Congruency",
  col = c("#CCCCCC", "#6699FF"),
  pt.bg = c("#CCCCCC", "#6699FF"),
  bg = c("white"),
  cex = 0.75
)

# Vorbereitung Fehlerbalken

# Cong
dat_graph$SD <- aggregate(rt ~ congruency + transition, dat, sd)[, 3]
dat_graph$n <- aggregate(rt ~ congruency + transition, dat, length)[, 3]
dat_graph$se <- dat_graph$SD / sqrt(dat_graph$n)

# Function für Fehlerbalken
fehlerbalken <- function(x, y, se, length = 0.1) {
  arrows(x, y + se, x, y - se, angle = 90, code = 3, length = length)
}

# Fehlerbalken hinzufügen
fehlerbalken(x = bplot, y = dat_graph$rt, se = dat_graph$se)

dev.off()
