ImportMangroveMySQL <- function(mysql.server.name, mysql.server.port, mysql.database, mysql.username, mysql.password, mysql.Mangrove.table = "2012_summary") {
    mydb <- dbConnect(MySQL(), user = mysql.username, password = mysql.password, dbname = mysql.database, host = mysql.server.name, port = mysql.server.port)
    ## Select all data from database
    study.data <- dbGetQuery(mydb, sprintf("select * from %s where SBP > 0 and PULSE>0 and RR>0 and GCSTOT>0", mysql.Mangrove.table))
    dbDisconnect(mydb) ## Disconnect from database
    study.data$SBP <- as.numeric(study.data$SBP)
    study.data$PULSE <- as.numeric(study.data$PULSE)
    study.data$RR <- as.numeric(study.data$RR)
    study.data$GCSTOT <- as.numeric(study.data$GCSTOT)
    return(study.data)
}

StoreLoopData <- function(executionID, repetitionCount, numberofupdatingevents, developmentprevalence, updatingvalidationprevalence, numberofupdatingnonevents, numberofdevelopmentnonevents, numberofvalidationnonevents, comparisonResult) {
    mydb <- dbConnect(MySQL(), user = mysql.username, password = mysql.password, dbname = mysql.database, host = mysql.server.name, port = mysql.server.port)
    dbSendQuery(mydb, sprintf("INSERT INTO `NTDB_adam`.`runtime_data` (`executionID`,`repetitionCount`, `numberofupdatingevents`, `developmentprevalence`,`updatingvalidationprevalence`, `numberofupdatingnonevents`, `numberofdevelopmentnonevents`,`numberofvalidationnonevents`,`comparisonResult`) VALUES (%s,%g,%g,%g,%g,%g,%g,%g,%g);", 
      executionID, repetitionCount, numberofupdatingevents, developmentprevalence, updatingvalidationprevalence, numberofupdatingnonevents, numberofdevelopmentnonevents, numberofvalidationnonevents, comparisonResult))
    dbDisconnect(mydb)
    return(1)
}