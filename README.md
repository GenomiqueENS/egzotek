# Egzotek
Egzotek is a bioinformatic pipeline designed for transcript annotation of non-model species with incomplete or poorly annotated genomes. It is developed to build a consensus annotated genome usig long RNA reads. 

![transcriptannotation_wf](https://github.com/GenomiqueENS/egzotek/blob/dev/transcript_annotation_wf.png)


1. Read orientation ([eoulsan](https://github.com/GenomiqueENS/eoulsan))
2. Transcript annotation with RNA-Bloom
   1. Transcript annotation ([rna-bloom](https://github.com/bcgsc/RNA-Bloom)) (optional short-read polishing)
   2. Genome mapping ([minimap2](https://github.com/lh3/minimap2))
   3. Bam to bed file conversion ([minimap2-paftools](https://github.com/lh3/minimap2))
   4. Bed to gff file conversion ([agat](https://github.com/NBISweden/AGAT))
   5. gff to gtf file conversion ([agat](https://github.com/NBISweden/AGAT))
3. Transcript annotation with Isoquant
   1. Genome mapping ([minimap2](https://github.com/lh3/minimap2))
   2. sam to bam file conversion ([samtools](https://github.com/samtools/samtools))
   3. Transcript annotation ([isoquant](https://github.com/ablab/IsoQuant))
5. Complement annotation ([agat](https://github.com/NBISweden/AGAT))
6. Clusterisation ([gffread](https://github.com/gpertea/gffread))

## Installing Egzotek
```bash
$ git clone git@github.com:GenomiqueENS/egzotek.git
$ cd egzotek
```
## Configuration
Customize runs by editing the nextflow.config file and/or specifying parameters at the command line.

## Usage
```bash
$ nextflow run transcript_annotation.nf
```

### Pipeline Input Parameters

Here are the primary input parameters for configuring the workflow:

| Parameter          | Description                                                   | Default Value                                 |
|--------------------|---------------------------------------------------------------|-----------------------------------------------|
| `reads`            | Path to the fastq files (required)                            | `test_data/matrix.csv`                        |
| `optional_shortread`       | Path to Illumina shortreads annotation .gtf file      | `null`                                        |
| `genome`           | Path to the genome .fasta file (required)                     | `test_data/test_bc.csv`                       |
| `annotation`       | Path to the reference transcriptome .gtf file (required)      | `test_data/transcriptome.fa`                  |
| `oriented`         | Orientation of reads based on library protocol (required)     | `false`                                       |

### Tools Parameters

Configuration of tools used for annotation process:

| Parameter          | Description                                                   | Default Value                                 |
|--------------------|---------------------------------------------------------------|-----------------------------------------------|
| `config`    | Path to Restrander configuration file (TSO and RTP sequences) (required if reads are non oriented)    | `/assets/PCB111.json`   |
| `intron_length`    | Parameter for maximum intron length for Minimap2              | `20000`                                       |
| `model_strategy`   | Parameter for transcript model construction algorithm         | `default_ont`                                 |

### Additional Parameters

| Parameter          | Description                                                   | Default Value                                 |
|--------------------|---------------------------------------------------------------|-----------------------------------------------|
| `outdir`           | Output directory for results                                  | `"results"`                                   |

### Run Parameters

Configuration for running the workflow:

| Parameter         | Description                        | Default Value             |
|-------------------|------------------------------------|---------------------------|
| `threads`         | Number of threads to use           | `4`                       |
| `docker.runOptions` | Docker run options to use       | `'-u $(id -u):$(id -g)'`  |

## Usage
User can choose among 4 ways to simulate template reads.
- use a real count matrix
- estimated the parameter from a real count matrix to simulate synthetic count matrix 
- specified by his/her own the input parameter
- a combination of the above options

We use SPARSIM tools to simulate count matrix. for more information a bout synthetic count matrix, please read [SPARSIM](https://gitlab.com/sysbiobig/sparsim/-/blob/master/vignettes/sparsim.Rmd?ref_type=heads#Sec_Input_parameter_estimated_from_data) documentaion.

### EXAMPLES 
##### Sample data
A demonstration dataset to initiate this workflow is accessible on zenodo DOI : [10.5281/zenodo.12731408](https://zenodo.org/records/12731409). This dataset is a subsample from a Nanopore run of the [10X 5k human pbmcs](https://www.10xgenomics.com/datasets/5k-human-pbmcs-3-v3-1-chromium-controller-3-1-standard).

The human GRCh38 [reference transcriptome](https://ftp.ensembl.org/pub/release-112/fasta/homo_sapiens/cdna/), [gtf annotation](https://ftp.ensembl.org/pub/release-112/gtf/homo_sapiens/) and [fasta referance genome](https://ftp.ensembl.org/pub/release-112/fasta/homo_sapiens/dna/) can be downloaded from Ensembl.


##### WITH NONORIENTED READS

```bash
 nextflow run main.nf --matrix dataset/sub_pbmc_matrice.csv \
                      --transcriptome dataset/Homo_sapiens.GRCh38.cdna.all.fa \
                      --features gene_name \
                      --gtf dataset/genes.gtf
```

##### WITH ORIENTED READS

```bash
 nextflow run main.nf --matrix dataset/sub_pbmc_matrice.csv \
                      --transcriptome dataset/Homo_sapiens.GRCh38.cdna.all.fa \
                      --features gene_name \
                      --gtf dataset/GRCh38-2020-A-genes.gtf \
                      --pcr_cycles 2 \
                      --pcr_dup_rate 0.7 \
                      --pcr_error_rate 0.00003
```

## Results

After execution, results will be available in the specified `--outdir`. This includes SAM and BAM files produced for IsoQuant and RNABloom and gtf with annotated transcriptomes.

## Cleaning Up

To clean up temporary files generated by Nextflow:

```bash
nextflow clean -f
```

## Support and Contributions

For support, please open an issue in the repository's "Issues" section. Contributions via Pull Requests are welcome. Follow the contribution guidelines specified in `CONTRIBUTING.md`.

## License

`Egzotek` is distributed under a specific license. Check the `LICENSE` file in the GitHub repository for details.
