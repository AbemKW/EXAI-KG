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

We use a unified script that enforces the **Seed 42** reproducibility standards for the project.

`ash
# Default: 1,000 patients with seed 42
./scripts/generate_data.sh

# Scale to 10,000 patients
./scripts/generate_data.sh -p 10000
`

The data will be saved to data/raw/synthea_<count>/.

## Controlled Perturbations

For Explainable AI validation, we inject controlled perturbations (lab noise and order variability) into the baseline cohort using a post-processing script.

```bash
# Activate virtual environment
source .venv/Scripts/activate

# Run perturbation pipeline
python src/pipeline/perturb_cohort.py
```

This will:
1. Inject Gaussian noise into numerical `Observation` resources.
2. Randomly drop or duplicate `MedicationRequest` entries.
3. Generate a `ground_truth_perturbations.json` answer key in `data/processed/`.
4. Modify the FHIR bundles in-place within `data/raw/synthea_10k/`.

## Reproducibility & Seeds

To ensure the research results are consistent across the team, we use fixed random seeds for both generation and perturbation:
- **Synthea Seed**: `42` (set in `generate_10k_baseline.ps1`)
- **Perturbation Seed**: `42` (set in `perturb_cohort.py`)

Due to disk space constraints, perturbations are applied **in-place** to the baseline data. The small `ground_truth_perturbations.json` file serves as the versioned record of all injected anomalies.

## Team

- Andy Behrens (PI) - Dakota State University
- Abem Woldesenbet - Dakota State University
- Daun Davids - Dakota State University


