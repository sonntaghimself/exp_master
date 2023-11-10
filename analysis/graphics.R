source(file = "./analysis.R")

################################################################################
#                                   Graphics                                   #
################################################################################
########################
#        Spende        #
########################
dat_graph <- aggregate(rt ~ congruency + task, dat, mean)


dat_graph$Nähe <- as.factor(dat_graph$Nähe)
dat_graph$Hoffnung <- as.factor(dat_graph$Hoffnung)


pdf("../nähe_hoffnung_spende.pdf", height = 5, width = 5, pointsize = 10)


bplot <- barplot(dat_graph$A101_01,
  xlab = "Message of:", ylab = "Spende",
  col = c("#CCCCCC", "#6699FF"), beside = TRUE, ylim = c(30, 80), xpd = FALSE
)

axis(side = 1, at = seq(0, 5), labels = FALSE, lwd.ticks = NA)
axis(side = 1, at = 1.3, expression(Fear))
axis(side = 1, at = 3.7, expression(Hope))
axis(side = 1, at = 2.5, labels = FALSE, tck = -.1)


legend(4, 70, expression(Fern, Nah),
  pch = c(21, 21),
  title = "Distanz",
  col = c("#CCCCCC", "#6699FF"),
  pt.bg = c("#CCCCCC", "#6699FF"),
  bg = c("white"),
  cex = 0.75
)

# Vorbereitung Fehlerbalken

# Cong
dat_graph$SD <- aggregate(A101_01 ~ Nähe + Hoffnung, dat, sd)[, 3]
dat_graph$n <- aggregate(A101_01 ~ Nähe + Hoffnung, dat, length)[, 3]
dat_graph$se <- dat_graph$SD / sqrt(dat_graph$n)

# Function für Fehlerbalken
fehlerbalken <- function(x, y, se, length = 0.1) {
  arrows(x, y + se, x, y - se, angle = 90, code = 3, length = length)
}

# Fehlerbalken hinzufügen
fehlerbalken(x = bplot, y = dat_graph$A101_01, se = dat_graph$se)

dev.off()
