import csv
import argparse
import sys

# Function to convert CSV to the exact YAML structure
def csv_to_exact_yaml(csv_file, yaml_file, path_prefix=None):
    data = {}

    # Reading the CSV file and grouping data by 'condition'
    with open(csv_file, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            condition = row['condition']
            if condition not in data:
                data[condition] = {"long read files": [], "labels": []}

            # Append the full path if path_prefix is provided
            fastq_file = f"{path_prefix}/{row['fastq']}.bam" if path_prefix else row['fastq']
            label = f"Sample{row['sample']}"
            
            data[condition]["long read files"].append(fastq_file)
            data[condition]["labels"].append(label)

    # Manually formatting the YAML data
    with open(yaml_file, 'w') as f:
        f.write("[\n")
        f.write('  data format: "fastq",\n')

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
    parser = argparse.ArgumentParser(description="Convert CSV to YAML and update fastq file paths")
    parser.add_argument('--input', required=True, help="Input CSV file")
    parser.add_argument('--output', required=True, help="Output YAML file")
    parser.add_argument('--path', help="Optional path to prepend to 'fastq' column values")

    args = parser.parse_args()

    # Convert the CSV to the YAML structure, appending the full path to 'fastq' if provided
    csv_to_exact_yaml(args.input, args.output, args.path)
    
    print(f"YAML file has been created: {args.output}")