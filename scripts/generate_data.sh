#!/bin/bash
# EXAI-KG Canonical Data Generator
# Enforces reproducibility and supports scaling for CPU-baseline research.

# Default values
PATIENTS=1000
SEED=42
OUTPUT_DIR="data/raw/synthea_${PATIENTS}"

# Usage help
usage() {
  echo "Usage: $0 [-p patients] [-s seed] [-o output_dir]"
  echo "  -p: Number of patients to generate (default: 1000)"
  echo "  -s: Random seed for reproducibility (default: 42)"
  echo "  -o: Custom output directory (default: data/raw/synthea_<p>)"
  exit 1
}

# Parse flags
while getopts "p:s:o:" opt; do
  case $opt in
    p) PATIENTS=$OPTARG ;;
    s) SEED=$OPTARG ;;
    o) OUTPUT_DIR=$OPTARG ;;
    *) usage ;;
  esac
done

# Navigate to project root
cd "$(dirname "$0")/.." || exit

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo "----------------------------------------------------------"
echo "EXAI-KG DATA GENERATION"
echo "Target: $PATIENTS patients"
echo "Seed:   $SEED"
echo "Output: $OUTPUT_DIR"
echo "----------------------------------------------------------"

# Build image
echo "Building Synthea Docker image..."
docker build -q -t exai-kg-synthea ./tools/synthea

# Run generation
echo "Running Synthea..."
export MSYS_NO_PATHCONV=1

docker run --rm \
  -v "$(pwd)/$OUTPUT_DIR:/app/output" \
  exai-kg-synthea \
  -p "$PATIENTS" \
  -s "$SEED"

echo "Success: Generated $PATIENTS patients in $OUTPUT_DIR"
