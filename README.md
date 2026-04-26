# EXAI-KG

Explainable AI with Knowledge Graphs applied to synthetic healthcare data.

This project builds an explainable AI pipeline over a knowledge graph constructed
from Synthea-generated synthetic patient records. The initial phase runs on CPU and
targets a conference paper. A GPU benchmarking phase follows, contingent on NVIDIA
grant funding, targeting a journal publication.

## Project structure

```
data/           # Synthea outputs and processed records (gitignored)
notebooks/      # Exploratory analysis
src/
  kg/           # Knowledge graph construction
  xai/          # Explainability components
  pipeline/     # End-to-end pipeline orchestration
experiments/    # Results and benchmark outputs
references/     # Papers and design docs (gitignored)
```

## Setup

Requires Python 3.10+ (Java is no longer required on the host machine).

```bash
python -m venv .venv
source .venv/Scripts/activate   # Windows (Git Bash)
pip install -r requirements.txt
```

## Generating synthetic data

We use a custom Docker container to run Synthea, avoiding the need for local Java dependencies.

To generate the initial 1,000 patient cohort, use the provided script:

```bash
# Build the Docker image and generate data
./scripts/generate_cohort.sh
```

The generated data (CSV/JSON files) will automatically be saved to `data/raw/synthea/`.

## Team

- Andy Behrens (PI) - Dakota State University
- Abem Woldesenbet - Dakota State University
- Daun Davids - Dakota State University