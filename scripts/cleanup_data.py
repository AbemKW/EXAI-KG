import os
import json
import shutil

def cleanup_corrupted_json(directory):
    files = [f for f in os.listdir(directory) if f.endswith('.json')]
    print(f"Scanning {len(files)} files in {directory}...")
    
    corrupted_count = 0
    for filename in files:
        file_path = os.path.join(directory, filename)
        
        # Check if file is empty
        if os.path.getsize(file_path) == 0:
            print(f"Removing empty file: {filename}")
            os.remove(file_path)
            corrupted_count += 1
            continue
            
        # Try to parse JSON
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                json.load(f)
        except (json.JSONDecodeError, UnicodeDecodeError) as e:
            print(f"Removing corrupted file: {filename} - Error: {e}")
            os.remove(file_path)
            corrupted_count += 1
            
    print(f"Cleanup complete. Removed {corrupted_count} files.")

if __name__ == "__main__":
    target_dir = r"projects/andy-research/projects/EXAI-KG/data/raw/synthea_10k/fhir"
    cleanup_corrupted_json(target_dir)
