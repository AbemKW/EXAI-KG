# Data

This directory holds Synthea-generated synthetic patient records and processed outputs.
All subdirectories are gitignored — do not commit patient data.

## Generating data

1. Download and install Synthea (requires Java)
2. Run: `java -jar synthea-with-dependencies.jar -p 1000` to generate 1000 patients
3. Move output to `data/synthea_output/`

See Synthea docs: https://github.com/synthetichealth/synthea
