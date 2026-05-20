import psycopg2
import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq
from pathlib import Path

DB_PARAMS = {
    "dbname": "omop_cdm",
    "user": "postgres",
    "password": "postgres",
    "host": "localhost",
    "port": 5432,
}

CDM_SCHEMA = "cdm_synthea"

CDM_TABLES = [
    "person",
    "condition_occurrence",
    "drug_exposure",
    "measurement",
    "observation",
    "visit_occurrence",
    "procedure_occurrence",
    "observation_period",
]

OUTPUT_DIR = Path("data/processed/omop_parquet")


def export_table(conn, schema: str, table: str, output_dir: Path):
    output_dir.mkdir(parents=True, exist_ok=True)
    df = pd.read_sql(f"SELECT * FROM {schema}.{table}", conn)
    out = output_dir / f"{table}.parquet"
    pq.write_table(pa.Table.from_pandas(df), out)
    print(f"Exported {schema}.{table} → {out} ({len(df)} rows)")


def main():
    conn = psycopg2.connect(**DB_PARAMS)
    for table in CDM_TABLES:
        export_table(conn, CDM_SCHEMA, table, OUTPUT_DIR)
    conn.close()
    print(f"\nDone. Files in {OUTPUT_DIR}/")


if __name__ == "__main__":
    main()
