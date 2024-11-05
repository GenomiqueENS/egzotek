import csv
import argparse
import sys

# Function to convert CSV to the exact YAML structure
def csv_to_exact_yaml(csv_file, yaml_file):
    data = {}

    # Reading the CSV file and grouping data by 'condition'
    with open(csv_file, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            condition = row['condition']
            if condition not in data:
                data[condition] = {"long read files": [], "labels": []}

            # Append .bam to the filename
            bam_file = f"{row['fastq']}.bam"
            label = f"Sample{row['sample']}"
            
            data[condition]["long read files"].append(bam_file)
            data[condition]["labels"].append(label)

    # Manually formatting the YAML data
    with open(yaml_file, 'w') as f:
        f.write("[\n")
        f.write('  data format: "bam",\n')

        for condition, details in data.items():
            f.write("  {\n")
            f.write(f'    name: "{condition}",\n')
            
            # Writing long read files in a formatted manner
            f.write("    long read files: [\n")
            for file in details["long read files"]:
                f.write(f'      "{file}",\n')
            f.write("    ],\n")
            
            # Writing labels in a formatted manner
            f.write("    labels: [\n")
            for label in details["labels"]:
                f.write(f'      "{label}",\n')
            f.write("    ]\n")
            f.write("  },\n")
        
        f.write("]\n")

# Main function to handle command-line arguments
if __name__ == "__main__":
    # Argument parsing
    parser = argparse.ArgumentParser(description="Convert CSV to YAML and append .bam to file names")
    parser.add_argument('--input', required=True, help="Input CSV file")
    parser.add_argument('--output', required=True, help="Output YAML file")

    args = parser.parse_args()

    # Convert the CSV to the YAML structure
    csv_to_exact_yaml(args.input, args.output)
    
    print(f"YAML file has been created: {args.output}")