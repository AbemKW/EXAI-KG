import json
import os
import random
import numpy as np
import pandas as pd
from pathlib import Path
from datetime import datetime

# Configuration
# For Week 2, we process in-place to save disk space
INPUT_DIR = Path("data/raw/synthea_10k/fhir")
GROUND_TRUTH_FILE = Path("data/processed/ground_truth_perturbations.json")
PERTURBATION_PROBABILITY = 0.05  # 5% of patients get perturbed
LAB_NOISE_STD_DEV = 0.5         # Standard deviation for Gaussian noise (relative)
RANDOM_SEED = 42                # Fixed seed for research reproducibility

# Initialize random seeds
random.seed(RANDOM_SEED)
np.random.seed(RANDOM_SEED)

# Ensure output directory for ground truth exists
GROUND_TRUTH_FILE.parent.mkdir(parents=True, exist_ok=True)

def perturb_observation(resource, patient_id):
    """Injects Gaussian noise into numerical observations."""
    if resource.get("resourceType") != "Observation":
        return None

    value_quantity = resource.get("valueQuantity")
    if not value_quantity or "value" not in value_quantity:
        return None

    original_value = value_quantity["value"]
    # Only perturb numerical values
    if not isinstance(original_value, (int, float)):
        return None

    # Apply Gaussian noise: value * (1 + N(0, std_dev))
    noise = np.random.normal(0, LAB_NOISE_STD_DEV)
    perturbed_value = original_value * (1 + noise)

    value_quantity["value"] = perturbed_value

    return {
        "patient_id": patient_id,
        "encounter_id": resource.get("encounter", {}).get("reference"),
        "resource_id": resource.get("id"),
        "resource_type": "Observation",
        "field": "valueQuantity.value",
        "original_value": original_value,
        "perturbed_value": perturbed_value,
        "perturbation_type": "gaussian_noise"
    }

def perturb_bundle_inplace(bundle_path):
    """Processes a single patient bundle and applies perturbations IN-PLACE."""
    with open(bundle_path, 'r', encoding='utf-8') as f:
        bundle = json.load(f)

    patient_id = bundle_path.stem
    perturbations = []

    # Decide if this patient should be perturbed
    if random.random() < PERTURBATION_PROBABILITY:
        entries = bundle.get("entry", [])

        # 1. Lab Noise
        for entry in entries:
            resource = entry.get("resource")
            if resource and resource.get("resourceType") == "Observation":
                # Only perturb a subset of observations (e.g., 20% chance if patient is selected)
                if random.random() < 0.2:
                    log = perturb_observation(resource, patient_id)
                    if log:
                        perturbations.append(log)

        # 2. Medication Order Variability (Drop/Duplicate)
        med_entries = [e for e in entries if e.get("resource", {}).get("resourceType") == "MedicationRequest"]
        if med_entries:
            # Randomly drop an order
            if random.random() < 0.3:
                idx_to_drop = random.randint(0, len(med_entries) - 1)
                dropped_resource = med_entries[idx_to_drop]["resource"]
                bundle["entry"].remove(med_entries[idx_to_drop])
                perturbations.append({
                    "patient_id": patient_id,
                    "resource_id": dropped_resource.get("id"),
                    "resource_type": "MedicationRequest",
                    "perturbation_type": "dropped_order"
                })

            # Randomly duplicate an order
            if random.random() < 0.3:
                idx_to_dup = random.randint(0, len(med_entries) - 1)
                dup_entry = json.loads(json.dumps(med_entries[idx_to_dup])) # Deep copy
                bundle["entry"].append(dup_entry)
                perturbations.append({
                    "patient_id": patient_id,
                    "resource_id": dup_entry.get("resource", {}).get("id"),
                    "resource_type": "MedicationRequest",
                    "perturbation_type": "duplicated_order"
                })

    # Save the (potentially) perturbed bundle IN-PLACE if modified
    if perturbations:
        with open(bundle_path, 'w', encoding='utf-8') as f:
            json.dump(bundle, f, indent=2)

    return perturbations

def main():
    print(f"Starting in-place perturbation pipeline on {INPUT_DIR}...")
    print(f"Using random seed: {RANDOM_SEED}")
    
    all_perturbations = []

    # Support both flat and nested FHIR directory structure
    json_files = list(INPUT_DIR.glob("*.json"))
    if not json_files:
        # Check parent if direct 'fhir' folder is empty
        json_files = list(Path("data/raw/synthea_10k/").glob("*.json"))

    if not json_files:
        print("No JSON files found. Is generation complete?")
        return

    total_files = len(json_files)
    for i, file_path in enumerate(json_files):
        if i % 100 == 0:
            print(f"Processing patient {i}/{total_files}...")
        
        logs = perturb_bundle_inplace(file_path)
        all_perturbations.extend(logs)

    # Use Pandas to finalize the ground truth log
    df = pd.DataFrame(all_perturbations)
    df.to_json(GROUND_TRUTH_FILE, orient="records", indent=2)
    
    print(f"Perturbation complete.")
    print(f"Total perturbations injected: {len(all_perturbations)}")
    print(f"Ground truth saved to {GROUND_TRUTH_FILE}")

if __name__ == "__main__":
    main()
