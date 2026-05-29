library("ETLSyntheaBuilder")
library("SqlRender")
library("DatabaseConnector")

pg_host          <- Sys.getenv("PG_HOST",          "postgres")
pg_port          <- as.integer(Sys.getenv("PG_PORT", "5432"))
pg_db            <- Sys.getenv("PG_DB",            "omop_cdm")
pg_user          <- Sys.getenv("PG_USER",          "postgres")
pg_password      <- Sys.getenv("PG_PASSWORD",      "postgres")
cdm_schema       <- Sys.getenv("CDM_SCHEMA",       "cdm_synthea")
synthea_schema   <- Sys.getenv("SYNTHEA_SCHEMA",   "native_synthea")
synthea_file_loc <- Sys.getenv("SYNTHEA_FILE_LOC", "/data/synthea_csv")
vocab_file_loc   <- Sys.getenv("VOCAB_FILE_LOC",   "/data/vocab")
cdm_version      <- Sys.getenv("CDM_VERSION",      "5.4")
synthea_version  <- Sys.getenv("SYNTHEA_VERSION",  "3.3.0")

cat("Connecting to PostgreSQL at", pg_host, "...\n")

connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms         = "postgresql",
  server       = paste0(pg_host, "/", pg_db),
  user         = pg_user,
  password     = pg_password,
  port         = pg_port,
  pathToDriver = "/jdbc"
)

cat("Step 0: Resetting schemas (drop + create)...\n")
conn <- DatabaseConnector::connect(connectionDetails)
DatabaseConnector::executeSql(
  conn,
  paste0(
    "DROP SCHEMA IF EXISTS ", cdm_schema, " CASCADE;",
    "DROP SCHEMA IF EXISTS ", synthea_schema, " CASCADE;",
    "CREATE SCHEMA ", cdm_schema, ";",
    "CREATE SCHEMA ", synthea_schema, ";"
  )
)
DatabaseConnector::disconnect(conn)

cat("Step 1: Creating CDM tables (schema:", cdm_schema, ")...\n")
ETLSyntheaBuilder::CreateCDMTables(connectionDetails, cdm_schema, cdm_version)

cat("Step 2: Creating native Synthea tables (schema:", synthea_schema, ")...\n")
ETLSyntheaBuilder::CreateSyntheaTables(connectionDetails, synthea_schema, synthea_version)

cat("Step 3: Loading Synthea CSVs from", synthea_file_loc, "...\n")
ETLSyntheaBuilder::LoadSyntheaTables(connectionDetails, synthea_schema, synthea_file_loc)

cat("Step 4: Loading OMOP vocabulary from", vocab_file_loc, "...\n")
ETLSyntheaBuilder::LoadVocabFromCsv(connectionDetails, cdm_schema, vocab_file_loc, delimiter = '\t')

cat("Step 4b: Creating CDM indices...\n")
indices_sql_path <- system.file(
  "ddl", cdm_version, "postgresql",
  paste0("OMOPCDM_postgresql_", cdm_version, "_indices.sql"),
  package = "CommonDataModel"
)
indices_sql <- paste(readLines(indices_sql_path), collapse = "\n")
indices_sql <- SqlRender::render(indices_sql, cdmDatabaseSchema = cdm_schema)
conn <- DatabaseConnector::connect(connectionDetails)
DatabaseConnector::executeSql(conn, indices_sql)
DatabaseConnector::disconnect(conn)

cat("Step 5: Creating map and rollup tables...\n")
ETLSyntheaBuilder::CreateMapAndRollupTables(connectionDetails, cdm_schema, synthea_schema, cdm_version, synthea_version)

cat("Step 6: Loading event tables...\n")
tryCatch(
  ETLSyntheaBuilder::LoadEventTables(connectionDetails, cdm_schema, synthea_schema, cdm_version, synthea_version),
  error = function(e) {
    cat("WARNING: LoadEventTables raised an error:", conditionMessage(e), "\n")
    cat("Verifying critical CDM tables are populated...\n")
  }
)

critical_tables <- c("person", "condition_occurrence", "drug_exposure",
                     "measurement", "observation", "visit_occurrence",
                     "procedure_occurrence", "observation_period")
conn <- DatabaseConnector::connect(connectionDetails)
empty <- character(0)
for (tbl in critical_tables) {
  n <- as.integer(DatabaseConnector::querySql(
    conn, paste0("SELECT count(*) FROM ", cdm_schema, ".", tbl))[1, 1])
  cat(sprintf("  %-22s %d rows\n", tbl, n))
  if (n == 0) empty <- c(empty, tbl)
}
DatabaseConnector::disconnect(conn)
if (length(empty) > 0) {
  stop("Critical CDM tables are empty: ", paste(empty, collapse = ", "))
}

cat("ETL complete.\n")
