library("ggplot2")
plot.data <- read.csv("./test-runtimeresult.csv")
str(plot.data)
ggplot(plot.data) +
    geom_line(aes(x = numberofupdatingevents, y = comparisonResult)) +
    facet_wrap(~developmentprevalence + updatingvalidationprevalence)
