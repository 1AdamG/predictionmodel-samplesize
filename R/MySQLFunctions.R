ImportMangroveMySQL <- function(mysql.server.name, mysql.server.port, mysql.database, mysql.username, mysql.password, mysql.Mangrove.table = "2012_summary") {
    mydb <- dbConnect(MySQL(), user = mysql.username, password = mysql.password, dbname = mysql.database, host = mysql.server.name, port = mysql.server.port)
    ## Select all data from database
    study.data <- dbGetQuery(mydb, sprintf("select * from %s", mysql.Mangrove.table))
    dbDisconnect(mydb) ## Disconnect from database
    study.data$SBP <- as.numeric(study.data$SBP)
    study.data$PULSE <- as.numeric(study.data$PULSE)
    study.data$RR <- as.numeric(study.data$RR)
    study.data$GCSTOT <- as.numeric(study.data$GCSTOT)
    return(study.data)
}

StoreLoopData <- function(executionID, loopCount, developmentprevalence, updatingvalidationprevalence, numberofdevelopmentnonevents, numberofvalidationnonevents, numberofupdatingnonevents, modelMIntercept, modelMSBP, modelMPULSE, modelMRR, modelMGCSTOT, modelUMIntercept, comparisonResult) {
    mydb <- dbConnect(MySQL(), user = mysql.username, password = mysql.password, dbname = mysql.database, host = mysql.server.name, port = mysql.server.port)
    dbSendQuery(mydb, sprintf("INSERT INTO `NTDB_adam`.`runtime_data` (`executionID`,`loopCount`,`developmentprevalence`,`updatingvalidationprevalence`,`numberofdevelopmentnonevents`,`numberofvalidationnonevents`,`numberofupdatingnonevents`,`modelMIntercept`,`modelMSBP`,`modelMPULSE`,`modelMRR`,`modelMGCSTOT`,`modelUMIntercept`,`comparisonResult`) VALUES (%s,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g);", executionID, loopCount, developmentprevalence, updatingvalidationprevalence, numberofdevelopmentnonevents, numberofvalidationnonevents, numberofupdatingnonevents, modelMIntercept, modelMSBP, modelMPULSE, modelMRR, modelMGCSTOT, modelUMIntercept, comparisonResult))
    #prepareStatement <- dbSendStatement(mydb, "INSERT INTO `NTDB_adam`.`runtime_data` (`executionID`,`loopCount`,`developmentprevalence`,`updatingvalidationprevalence`,`numberofdevelopmentnonevents`,`numberofvalidationnonevents`,`numberofupdatingnonevents`,`modelMIntercept`,`modelMSBP`,`modelMPULSE`,`modelMRR`,`modelMGCSTOT`,`modelUMIntercept`,`comparisonResult`) VALUES (@a1,  @a2,  @a3,  @a4,  @a5,  @a6,  @a7,  @a8,  @a9,  @a10,  @a11,  @a12,  @a13,  @a14)")
    #dbBind(prepareStatement, list(executionID, loopCount, developmentprevalence, updatingvalidationprevalence, numberofdevelopmentnonevents, numberofvalidationnonevents, numberofupdatingnonevents, modelMIntercept, modelMSBP, modelMPULSE, modelMRR, modelMGCSTOT, modelUMIntercept, comparisonResult))
    dbDisconnect(mydb)
    return(1)
}