# EXAI-KG — Phase 1: OMOP CDM ETL Pipeline

Transforms Synthea synthetic patient data into OMOP CDM format for downstream knowledge graph construction.

## Pipeline

Synthea (Docker) → CSV → ETL-Synthea (Docker, R) → PostgreSQL OMOP CDM → Parquet

## Prerequisites

- Docker + Docker Compose
- Python 3.9+ with venv
- OMOP Vocabulary files in `data/vocab/` (download from https://athena.ohdsi.org)

## Setup

```bash
python -m venv .venv
source .venv/Scripts/activate   # Windows Git Bash
pip install -r requirements.txt
```

## Running the pipeline

```bash
# Full end-to-end (1k patients, seed 42)
./scripts/run_pipeline.sh

# Custom run
./scripts/run_pipeline.sh -p 5000 -s 99

# After pipeline: export to Parquet
python scripts/convert_to_parquet.py
```

## Validating

```bash
# Standalone validator (prints OK/WARN/FAIL per table)
python scripts/validate_omop.py

# Full pytest suite
pytest tests/test_pipeline.py -v
```

## Data layout

```
data/
  raw/synthea_1k_csv/csv/   # Synthea CSV output (gitignored)
  vocab/                    # OMOP vocabulary files (gitignored)
  processed/omop_parquet/   # Parquet export (gitignored)
```

## Schemas

- `native_synthea` — raw Synthea tables loaded by ETL-Synthea
- `cdm_synthea` — OMOP CDM v5.4 tables populated by ETL-Synthea
