library(dbConnect)
library(DBI)
library(doParallel)
library(foreach)
library(dplyr)
## Initialize
set.seed(41738)
## setwd("/home/adam/Desktop/source/repos/predictionmodel-samplesize")
source("../.sshconfig.R")
source("R/MySQLFunctions.R")
source("R/CreateSubSample.R")
source("R/CompareModels.R")
## Settings

## Note that it is the number of events in datasetB that should vary between 1
## and 1000, but that the outcome prevalence should be the same in datasetC and
## datasetB. So if the prevelance is 0.02, and the number of events is 1, then
## the number of patients in datasetB should be 50, because 1/0.02=50.

## The number of events in datasetA and C should always be 200, and the number
## of non-events should vary depending on the outcome prevalence
numberofevents <- 200
prevalenceinterval <- c(0.02, 0.05, 0.10)

#Get Datasets
print("Get Datasets")
datasetA <- ImportMangroveMySQL(mysql.server.name, mysql.server.port, mysql.database, mysql.username, mysql.password, mysql.Mangrove.table = '2012_summary')
datasetB <- ImportMangroveMySQL(mysql.server.name, mysql.server.port, mysql.database, mysql.username, mysql.password, mysql.Mangrove.table = '2013_summary')
datasetC <- ImportMangroveMySQL(mysql.server.name, mysql.server.port, mysql.database, mysql.username, mysql.password, mysql.Mangrove.table = '2014_summary')

executionID <- format(Sys.time(), "%Y%m%d%H%M%OS")
allprevalences <- data.frame(t(expand.grid(prevalenceinterval, prevalenceinterval)))
RunStudy <- function(numberofupdatingevents,repetitionCount) {
#numberofupdatingevents<-200; repetitionCount <- 1
    gc()

    #Start loop confindence (0.02, 0.05, 0.10) changes with each loop. Note that the
    #outcome prevelance should always be the same in datasetB and datasetC

    for (prevalenceArr in allprevalences) {
        developmentprevalence <- prevalenceArr[1]
        updatingvalidationprevalence <- prevalenceArr[2]

        ## Now define the number of non-events
        numberofdevelopmentnonevents <- ceiling((numberofevents / developmentprevalence) - numberofevents)
        numberofvalidationnonevents <- ceiling((numberofevents / updatingvalidationprevalence) - numberofevents)
        numberofupdatingnonevents <- ceiling((numberofupdatingevents / updatingvalidationprevalence) - numberofupdatingevents)

        ## Get developing data (datasetA), get events and non-events, choose sample size and join together
        sample.dataset.A <- CreateSubSample(datasetA, numberofevents, numberofdevelopmentnonevents)

        ## Ceate model
        modelM <- glm(Event ~ SBP + PULSE + RR + GCSTOT, data = sample.dataset.A, family = 'binomial')

        ## Get updating data (Dataset B), select sample
        sample.dataset.B <- CreateSubSample(datasetB, numberofupdatingevents, numberofupdatingnonevents)
        
        ## Get validation data (DatasetC) and select sample 
        sample.dataset.C <- CreateSubSample(datasetC, numberofevents, numberofvalidationnonevents)

        ## Update model
        sample.dataset.B$lp <- predict(modelM, newdata = sample.dataset.B)
        modelUM <- glm(Event ~ lp, data = sample.dataset.B, family = binomial)

        ## Set return values to 999. These values will only be returned if the
        ## updating procedure does not converge (likely with few events)
        comparisonResult <- 999
        calibrationSlopeUM <- 999
        calibrationSlopeM <- 999
        ## Check if the updating procedure converged
        if (modelUM$converged) {

            ## Get crude model parameters
            modelMIntercept <- coef(modelM)["(Intercept)"]
            modelMSBP <- coef(modelM)["SBP"]
            modelMPULSE <- coef(modelM)["PULSE"]
            modelMRR <- coef(modelM)["RR"]
            modelMGCSTOT <- coef(modelM)["GCSTOT"]

            ## Get updated model parameters
            modelUMIntercept <- coef(modelUM)["(Intercept)"]
            modelUMLP <- coef(modelUM)["lp"]

            ## Use both M and UM to predict in validation sample, starting with
            ## M
            sample.dataset.C$Mlp <- with(sample.dataset.C, modelMIntercept + modelMSBP * SBP + modelMPULSE * PULSE + modelMRR * RR + modelMGCSTOT * GCSTOT)

            ## Convert M's linear predictor to probability
            sample.dataset.C$Mp <- 1/(1 + exp(-sample.dataset.C$Mlp))
            
            ## Repeat with UM
            sample.dataset.C$UMlp <- with(sample.dataset.C, modelUMIntercept +
                                                            modelUMLP * (modelMIntercept + modelMSBP * SBP + modelMPULSE * PULSE + modelMRR * RR + modelMGCSTOT * GCSTOT))
            sample.dataset.C$UMp <- 1/(1 + exp(-sample.dataset.C$UMlp))

            ## Compare results from both models
            cm <- with(sample.dataset.C, CompareModels(UMp, Mp, Event))

            ## Get results
            comparisonResult <- cm$bias.diff
            calibrationSlopeUM <- cm$calibration.slope.UM
            calibrationSlopeM <- cm$calibration.slope.M
        }
        
        ## Store data
        StoreLoopData(executionID, repetitionCount, numberofupdatingevents, developmentprevalence, updatingvalidationprevalence, comparisonResult, calibrationSlopeUM, calibrationSlopeM,
                      test = FALSE)
    }
  return(1)
}

print("Starting to use multple cores")

myCluster <- makeCluster(detectCores(), type = "FORK") # why "FORK"?
registerDoParallel(myCluster)

init <- Sys.time()

print("Loop starting")

#Start loop number of updating events (1-1000) changes with each loop
updatingevents <- c(1:1000)
repeattimesforconfidence <- 1:1 #should be 1000 times

foreach(rtfc = repeattimesforconfidence, .combine = c) %do% {
  foreach(noue = updatingevents, .combine = c) %dopar% {
    RunStudy(noue,rtfc)
  }
}

print(Sys.time() - init)
stopCluster(myCluster)
print("Finished using multiple cores")

