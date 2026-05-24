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

cat("Step 1: Creating CDM tables (schema:", cdm_schema, ")...\n")
ETLSyntheaBuilder::CreateCDMTables(connectionDetails, cdm_schema, cdm_version)

cat("Step 2: Creating native Synthea tables (schema:", synthea_schema, ")...\n")
ETLSyntheaBuilder::CreateSyntheaTables(connectionDetails, synthea_schema, synthea_version)

cat("Step 3: Loading Synthea CSVs from", synthea_file_loc, "...\n")
ETLSyntheaBuilder::LoadSyntheaTables(connectionDetails, synthea_schema, synthea_file_loc)

cat("Step 4: Loading OMOP vocabulary from", vocab_file_loc, "...\n")
ETLSyntheaBuilder::LoadVocabFromCsv(connectionDetails, cdm_schema, vocab_file_loc, delimiter = '\t')

cat("Step 5: Creating map and rollup tables...\n")
ETLSyntheaBuilder::CreateMapAndRollupTables(connectionDetails, cdm_schema, synthea_schema, cdm_version, synthea_version)

cat("Step 6: Loading event tables...\n")
ETLSyntheaBuilder::LoadEventTables(connectionDetails, cdm_schema, synthea_schema, cdm_version, synthea_version)

cat("ETL complete.\n")
