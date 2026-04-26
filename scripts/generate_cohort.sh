#!/bin/bash
# Generate 1,000 synthetic patient records using Synthea via Docker

# Navigate to the project root
cd "$(dirname "$0")/.." || exit

echo "Building the Synthea Docker image..."
docker build -t exai-kg-synthea ./tools/synthea

echo "Running Synthea to generate 1,000 patients..."
# Mount the local data/raw/synthea directory to /app/output in the container
# Synthea automatically outputs to ./output when run from the JAR
docker run --rm -v "$(pwd)/data/raw/synthea:/app/output" exai-kg-synthea -p 1000

echo "Data generation complete. Output saved to data/raw/synthea/"
