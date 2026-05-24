#!/bin/bash
set -e

PATIENTS=1000
SEED=42

while getopts "p:s:" opt; do
  case $opt in
    p) PATIENTS=$OPTARG ;;
    s) SEED=$OPTARG ;;
    *) echo "Usage: $0 [-p patients] [-s seed]"; exit 1 ;;
  esac
done

OUTPUT_DIR="data/raw/synthea_${PATIENTS}_csv"

echo "=============================="
echo "EXAI-KG Phase 1 Pipeline"
echo "Patients: $PATIENTS | Seed: $SEED"
echo "=============================="

echo "[1/4] Generating Synthea CSV..."
./scripts/generate_data.sh -p "$PATIENTS" -s "$SEED" -o "$OUTPUT_DIR"

echo "[2/4] Starting PostgreSQL..."
docker compose up -d postgres
docker compose exec postgres sh -c "until pg_isready -U postgres; do sleep 1; done"

echo "[3/4] Running ETL-Synthea..."
docker compose --profile etl run --rm \
  -v "$(pwd)/$OUTPUT_DIR/csv:/data/synthea_csv:ro" \
  -e SYNTHEA_FILE_LOC=/data/synthea_csv \
  etl-synthea

echo "[4/4] Validating OMOP output..."
source .venv/Scripts/activate 2>/dev/null || source .venv/bin/activate
python scripts/validate_omop.py

echo ""
echo "Pipeline complete. Run: python scripts/convert_to_parquet.py"
