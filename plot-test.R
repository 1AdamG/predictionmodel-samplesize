library("ggplot2")
plot.data <- read.csv("./100rep-runtimeresult.csv")
str(plot.data.1)
plot.data.1 <- plot.data[plot.data$repetitionCount == 1,]
plot.data.1[plot.data.1 == 999] <- NA
ggplot(plot.data.1) +
    geom_line(aes(x = numberofupdatingevents, y = comparisonResult)) +
    facet_wrap(~developmentprevalence + updatingvalidationprevalence)
