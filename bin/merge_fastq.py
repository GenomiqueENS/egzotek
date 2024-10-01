import pandas as pd
import os
import gzip
import shutil
import argparse

def merge_fastq_by_condition(samplesheet_path, fastq_dir):
    # Supported extensions
    file_extensions = ['.fastq.gz', '.fastq', '.fq.gz', '.fq', '.fasta', '.fasta.gz']

    # Read the samplesheet CSV file
    samplesheet = pd.read_csv(samplesheet_path)

    # Get the unique conditions
    conditions = samplesheet['condition'].unique()

    # Merge fastq files by condition
    for condition in conditions:
        # Get the list of fastq files for this condition
        condition_fastqs = samplesheet[samplesheet['condition'] == condition]['fastq']

        # Create an output file for the merged fastq files in gzipped format
        output_file = os.path.join(os.getcwd(), f"{condition}.fastq.gz")  # Save in current working directory

        # Open the output file in write mode for gzip
        with gzip.open(output_file, 'wb') as outfile:
            # Loop through each fastq file for this condition
            for fastq in condition_fastqs:
                found_file = None

                # Try finding the fastq file with any of the supported extensions
                for ext in file_extensions:
                    fastq_path = os.path.join(fastq_dir, f"{fastq}{ext}")
                    if os.path.exists(fastq_path):
                        found_file = fastq_path
                        break

                if found_file:
                    # If the file is compressed (.gz), read it as is
                    if found_file.endswith('.gz'):
                        with gzip.open(found_file, 'rb') as infile:
                            shutil.copyfileobj(infile, outfile)
                    else:
                        # For uncompressed files, read and write them directly
                        with open(found_file, 'rb') as infile:
                            shutil.copyfileobj(infile, outfile)
                else:
                    print(f"Warning: No file found for {fastq} with supported extensions.")
    
    print("Merging complete!")

if __name__ == "__main__":
    # Parse command-line arguments
    parser = argparse.ArgumentParser(description="Merge fastq files by condition.")
    parser.add_argument('samplesheet', type=str, help="Path to the samplesheet CSV file")
    parser.add_argument('fastq_dir', type=str, help="Directory containing fastq and sequence files")

    args = parser.parse_args()

    # Run the merge function with command-line arguments
    merge_fastq_by_condition(args.samplesheet, args.fastq_dir)