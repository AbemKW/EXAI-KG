param (
    [int]$p = 10000,
    [long]$s = 42
)

# Generate synthetic patient records using Synthea via Docker (Baseline)
# Fixed seed ($s) used for research reproducibility per Week 2 agreement.

$projectRoot = "projects/andy-research/projects/EXAI-KG"
$outputDir = "$projectRoot/data/raw/synthea_10k"

# Create the output directory if it doesn't exist
If (!(Test-Path $outputDir)) {
    New-Item -ItemType Directory -Force -Path $outputDir
}

Write-Host "Building the Synthea Docker image..."
docker build -q -t exai-kg-synthea "$projectRoot/tools/synthea"

Write-Host "Running Synthea to generate $p patients with seed $s..."
# Mount the local directory to /app/output in the container
$absOutputDir = (Resolve-Path $outputDir).Path.Replace('\', '/')
if ($absOutputDir -match '^[A-Z]:') {
    $drive = $absOutputDir.Substring(0, 1).ToLower()
    $rest = $absOutputDir.Substring(2)
    $absOutputDir = "/$drive$rest"
}

docker run --rm -v "${absOutputDir}:/app/output" exai-kg-synthea -p $p -s $s

Write-Host "Data generation complete. Output saved to $outputDir"
