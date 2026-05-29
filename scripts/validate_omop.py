import psycopg2
import sys

DB_PARAMS = {
    "dbname": "omop_cdm",
    "user": "postgres",
    "password": "postgres",
    "host": "localhost",
    "port": 5432,
}

TABLES = [
    ("cdm_synthea",    "person"),
    ("cdm_synthea",    "condition_occurrence"),
    ("cdm_synthea",    "drug_exposure"),
    ("cdm_synthea",    "measurement"),
    ("cdm_synthea",    "observation"),
    ("cdm_synthea",    "visit_occurrence"),
    ("native_synthea", "patients"),
    ("native_synthea", "conditions"),
    ("native_synthea", "medications"),
]

def validate():
    try:
        conn = psycopg2.connect(**DB_PARAMS)
    except Exception as e:
        print(f"FAIL: Cannot connect to PostgreSQL: {e}")
        sys.exit(1)

    cur = conn.cursor()
    all_passed = True

    for schema, table in TABLES:
        cur.execute(
            "SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema=%s AND table_name=%s)",
            (schema, table),
        )
        if not cur.fetchone()[0]:
            print(f"FAIL  {schema}.{table} — does not exist")
            all_passed = False
            continue

        cur.execute(f"SELECT COUNT(*) FROM {schema}.{table}")
        count = cur.fetchone()[0]
        tag = "OK  " if count > 0 else "WARN"
        print(f"{tag}  {schema}.{table} — {count} rows")
        if count == 0:
            all_passed = False

    conn.close()
    if all_passed:
        print("\nValidation passed.")
    else:
        print("\nValidation failed — check ETL logs.")
        sys.exit(1)

if __name__ == "__main__":
    validate()
