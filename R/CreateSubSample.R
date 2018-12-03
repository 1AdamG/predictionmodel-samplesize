## The steps to create a subsample could be encapsulated as a function to avoid
## code duplication
CreateSubSample <- function(dataset, number.of.events, number.of.nonevents) {
    set.seed(89);
    #Bootstrap dataset
    datasetBootstrap <- dataset#[sample(nrow(dataset), nrow(dataset), replace = TRUE),]
    
    #Pick events and nonevents
    subsample <- bind_rows(sample_n(filter(dataset, Event == 1), number.of.events, replace = FALSE),sample_n(filter(dataset, Event == 0), number.of.nonevents, replace = FALSE))
    return(subsample)
}