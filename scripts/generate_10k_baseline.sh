#!/bin/bash
# Generate 10,000 synthetic patient records using Synthea via Docker (Baseline)

# Navigate to the project root
cd "$(dirname "$0")/.." || exit

# Create the output directory if it doesn't exist
mkdir -p data/raw/synthea_10k

echo "Building the Synthea Docker image..."
docker build -t exai-kg-synthea ./tools/synthea

echo "Running Synthea to generate 10,000 patients..."
# Mount the local data/raw/synthea_10k directory to /app/output in the container
docker run --rm -v "$(pwd)/data/raw/synthea_10k:/app/output" exai-kg-synthea -p 10000

echo "Data generation complete. Output saved to data/raw/synthea_10k/"
