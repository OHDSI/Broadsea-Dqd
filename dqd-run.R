#!/usr/bin/Rscript

library(DataQualityDashboard)

PASSWORD <- Sys.getenv("OHDSI_ADMIN_PASSWORD")
OMOP_DB <- paste0(Sys.getenv("OMOP_DB"), "/ohdsi")
OMOP_DB_PORT <- Sys.getenv("OMOP_DB_PORT")
CDM_DB_SCHEMA <- Sys.getenv("CDM_DB_SCHEMA")
RESULTS_DB_SCHEMA <- Sys.getenv("RESULTS_DB_SCHEMA")
CDM_SOURCE_NAME <- Sys.getenv("CDM_SOURCE_NAME")

# fill out the connection details -----------------------------------------------------------------------
connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "postgresql",
                                                              user = "ohdsi_admin_user",
                                                              password = PASSWORD,
                                                              server = OMOP_DB,
                                                              port = OMOP_DB_PORT,
                                                              extraSettings = "")

#cdmDatabaseSchema <- "cds_cdm" # the fully qualified database schema name of the CDM
#resultsDatabaseSchema <- "cds_results" # the fully qualified database schema name of the results schema (that you can write to)
cdmDatabaseSchema <- CDM_DB_SCHEMA # the fully qualified database schema name of the CDM
resultsDatabaseSchema <- RESULTS_DB_SCHEMA # the fully qualified database schema name of the results schema (that you can write to)
cdmSourceName <- CDM_SOURCE_NAME # a human readable name for your CDM source

# determine how many threads (concurrent SQL sessions) to use ----------------------------------------
numThreads <- 1 # on Redshift, 3 seems to work well

# specify if you want to execute the queries or inspect them ------------------------------------------
sqlOnly <- FALSE # set to TRUE if you just want to get the SQL scripts and not actually run the queries

# where should the logs go? -------------------------------------------------------------------------
outputFolder <- "/tmp/output"

# logging type -------------------------------------------------------------------------------------
verboseMode <- TRUE # set to TRUE if you want to see activity written to the console

# write results to table? ------------------------------------------------------------------------------
writeToTable <- TRUE # set to FALSE if you want to skip writing to a SQL table in the results schema

# write results to a csv file? -----------------------------------------------------------------------
writeToCsv <- TRUE # set to FALSE if you want to skip writing to csv file
csvFile <- "results.csv" # only needed if writeToCsv is set to TRUE

# if writing to table and using Redshift, bulk loading can be initialized -------------------------------

# Sys.setenv("AWS_ACCESS_KEY_ID" = "",
#            "AWS_SECRET_ACCESS_KEY" = "",
#            "AWS_DEFAULT_REGION" = "",
#            "AWS_BUCKET_NAME" = "",
#            "AWS_OBJECT_KEY" = "",
#            "AWS_SSE_TYPE" = "AES256",
#            "USE_MPP_BULK_LOAD" = TRUE)

# which DQ check levels to run -------------------------------------------------------------------
checkLevels <- c("TABLE", "FIELD", "CONCEPT")

# which DQ checks to run? ------------------------------------

checkNames <- c() # Names can be found in inst/csv/OMOP_CDM_v5.3_Check_Descriptions.csv

# run the job --------------------------------------------------------------------------------------
DataQualityDashboard::executeDqChecks(connectionDetails = connectionDetails,
                                    cdmDatabaseSchema = cdmDatabaseSchema,
                                    resultsDatabaseSchema = resultsDatabaseSchema,
                                    cdmSourceName = cdmSourceName,
                                    numThreads = numThreads,
                                    sqlOnly = sqlOnly,
                                    outputFolder = outputFolder,
                                    outputFile = "results.json",
                                    verboseMode = verboseMode,
                                    writeToTable = writeToTable,
                                    writeToCsv = writeToCsv,
                                    csvFile = csvFile,
                                    checkLevels = checkLevels,
                                    checkNames = checkNames)

# inspect logs ----------------------------------------------------------------------------
#ParallelLogger::launchLogViewer(logFileName = file.path(outputFolder, cdmSourceName,
#                                                      sprintf("log_DqDashboard_%s.txt", cdmSourceName)))

# (OPTIONAL) if you want to write the JSON file to the results table separately -----------------------------
#jsonFilePath <- "output/results.json"
#DataQualityDashboard::writeJsonResultsToTable(connectionDetails = connectionDetails,
#                                            resultsDatabaseSchema = resultsDatabaseSchema,
#                                            jsonFilePath = jsonFilePath)

Sys.setenv(jsonPath = "/tmp/output/results.json")
appDir <- system.file("shinyApps", package = "DataQualityDashboard")
shiny::runApp(appDir = appDir,
              display.mode = "normal",
              launch.browser = FALSE,
              host="0.0.0.0",
              port=3838)
