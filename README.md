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

Requires Python 3.10+ and Java (for Synthea).

```bash
python -m venv .venv
source .venv/Scripts/activate   # Windows (Git Bash)
pip install -r requirements.txt
```

## Generating synthetic data

Download the [Synthea JAR](https://github.com/synthetichealth/synthea/releases)
and run:

```bash
java -jar synthea-with-dependencies.jar -p 1000
```

Move the output into `data/synthea_output/`. See `data/README.md` for details.

## Team

- Andy Behrens (PI) — Dakota State University
- Abem Woldesenbet — Dakota State University
- Daun Davids — Dakota State University
