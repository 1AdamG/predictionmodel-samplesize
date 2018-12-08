CompareModels <- function(UMp, Mp, outcomes) {
    ## Mp is a vector of probabilities estimated by the crude model from the
    ## development sample. UMp is a vector of probabilities estimated by the
    ## updated model. outcomes is a vector of outcomes from the validation
    ## sample.

    CalculateCalibrationSlope <- function(p, outcomes) {
        ## p is a vector of probabilities. outcomes is a vector of outcomes.

        ## Divide each vector of probabilities into ten quantiles
        qs <- quantile(p, probs = seq(0, 1, 0.1))
        groups <- cut(p, qs, include.lowest = TRUE)
        ## Calculate mean probability and mean outcome in each group
        means <- lapply(levels(as.factor(groups)), function(level) {
            mean <- c(mean(outcomes[groups == level]), mean(p[groups == level]))
            return(mean)
        })
        ## Combine into data frame
        mean.data <- data.frame(do.call(rbind, means))
        colnames(mean.data) <- c("mean.outcome", "mean.p")
        ## Estimate calibration slope
        cs <- coef(glm(mean.outcome ~ mean.p, data = mean.data))["mean.p"]
        return(cs)
    }
    
    ## Calculate calibration slopes
    calibration.slopes <- lapply(setNames(list(UMp, Mp), c("UMp", "Mp")),
                                 CalculateCalibrationSlope,
                                 outcomes = outcomes)
    ## Transform into bias estimates. The bias estimate is calculated by taking
    ## the absolute value of the log transformed calibration slope. The reason
    ## for doing this is that a calibration slope of 0.5 indicates an
    ## overestimation of the risk with factor 2, i.e. the bias of this estimate
    ## should be the same as the bias associated with a calibration slope of
    ## 2. The bias metric is a measure of the distance between the current
    ## calibration slope and an perfect calibration slope, on the log scale.
    bias.estimates <- lapply(calibration.slopes, function(slope) abs(log(slope)))
    ## Calculate difference in bias estimates. A negative value indicates that
    ## the updated model is better than the crude model.
    bias.diff <- with(bias.estimates, UMp - Mp)
    ## Create return list
    return.list <- list(bias.diff = bias.diff,
                        calibration.slope.UM = calibration.slopes$UMp,
                        calibration.slope.M = calibration.slopes$Mp)
    return(return.list)
}
