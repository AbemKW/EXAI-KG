import pytest
import psycopg2

DB_PARAMS = {
    "dbname": "omop_cdm",
    "user": "postgres",
    "password": "postgres",
    "host": "localhost",
    "port": 5432,
}

CDM_SCHEMA = "cdm_synthea"
NATIVE_SCHEMA = "native_synthea"

EXPECTED_CDM_TABLES = [
    "person",
    "condition_occurrence",
    "drug_exposure",
    "measurement",
    "observation",
    "visit_occurrence",
]

@pytest.fixture(scope="module")
def conn():
    c = psycopg2.connect(**DB_PARAMS)
    yield c
    c.close()

@pytest.mark.parametrize("table", EXPECTED_CDM_TABLES)
def test_cdm_table_exists(conn, table):
    cur = conn.cursor()
    cur.execute(
        "SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema=%s AND table_name=%s)",
        (CDM_SCHEMA, table),
    )
    assert cur.fetchone()[0], f"CDM table {CDM_SCHEMA}.{table} does not exist"

@pytest.mark.parametrize("table", EXPECTED_CDM_TABLES)
def test_cdm_table_populated(conn, table):
    cur = conn.cursor()
    cur.execute(f"SELECT COUNT(*) FROM {CDM_SCHEMA}.{table}")
    count = cur.fetchone()[0]
    assert count > 0, f"{CDM_SCHEMA}.{table} is empty"

def test_person_count_matches_native_patients(conn):
    cur = conn.cursor()
    cur.execute(f"SELECT COUNT(*) FROM {NATIVE_SCHEMA}.patients")
    native_count = cur.fetchone()[0]
    cur.execute(f"SELECT COUNT(*) FROM {CDM_SCHEMA}.person")
    cdm_count = cur.fetchone()[0]
    assert cdm_count == native_count, (
        f"cdm_synthea.person ({cdm_count}) != native_synthea.patients ({native_count})"
    )

import os
import pandas as pd

PARQUET_DIR = "data/processed/omop_parquet"

EXPECTED_PARQUET = [
    "person.parquet",
    "condition_occurrence.parquet",
    "drug_exposure.parquet",
    "measurement.parquet",
    "observation.parquet",
    "visit_occurrence.parquet",
]

@pytest.mark.parametrize("filename", EXPECTED_PARQUET)
def test_parquet_file_exists(filename):
    assert os.path.exists(os.path.join(PARQUET_DIR, filename)), \
        f"Missing: {PARQUET_DIR}/{filename}"

def test_person_parquet_row_count(conn):
    df = pd.read_parquet(f"{PARQUET_DIR}/person.parquet")
    cur = conn.cursor()
    cur.execute(f"SELECT COUNT(*) FROM {CDM_SCHEMA}.person")
    assert len(df) == cur.fetchone()[0]
