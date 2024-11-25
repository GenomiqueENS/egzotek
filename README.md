# Egzotek
Egzotek is a bioinformatic pipeline designed for transcript annotation of non-model species with incomplete or poorly annotated genomes. It is developed to build a consensus annotated genome usig long RNA reads. 

![transcriptannotation_wf](https://github.com/GenomiqueENS/egzotek/blob/dev/transcript_annotation_wf.png)

1. Read orientation
   1. Oriented protocol ([eoulsan](https://github.com/GenomiqueENS/eoulsan))
   2. Non-oriented protocol ([restrander](https://github.com/mritchielab/restrander))
3. Transcript annotation with RNA-Bloom
   1. Transcript annotation ([rna-bloom](https://github.com/bcgsc/RNA-Bloom)) (with optional short-read polishing)
   2. Genome mapping ([minimap2](https://github.com/lh3/minimap2))
   3. Bam to bed file conversion ([minimap2-paftools](https://github.com/lh3/minimap2))
   4. Bed to gff file conversion ([agat](https://github.com/NBISweden/AGAT))
   5. Gff to gtf file conversion ([agat](https://github.com/NBISweden/AGAT))
4. Transcript annotation with Isoquant
   1. Genome mapping ([minimap2](https://github.com/lh3/minimap2))
   2. Sam to bam file conversion ([samtools](https://github.com/samtools/samtools))
   3. Transcript annotation ([isoquant](https://github.com/ablab/IsoQuant))
5. Complement annotation ([agat](https://github.com/NBISweden/AGAT))
6. Clusterisation ([gffread](https://github.com/gpertea/gffread))
7. Merge annotation

## Installing Egzotek
```bash
$ git clone git@github.com:GenomiqueENS/egzotek.git
$ cd egzotek
```
## Configuration
Customize runs by editing the nextflow.config file and/or specifying parameters at the command line.

## Usage
When running Egzotek locally:
```bash
$ nextflow run main.nf
```
When running Egzotek remotely:
```bash
$ nextflow run genomiqueens/egzotek -c nextflow.config
```
The config file needs to be modified with the path to your data and the type of analysis you wish to run.

### Pipeline Input Parameters

Here are the primary input parameters for configuring the workflow:

| Parameter          | Description                                                   | Default Value                                 |
|--------------------|---------------------------------------------------------------|-----------------------------------------------|
| `reads`            | Path to the fastq files (required)                            | `/path/to/data/*.fasta`                       |
| `samplesheet`      | Path to the samplesheet file (required)                       | `/path/to/data/samplesheet.csv`               |
| `genome`           | Path to the genome .fasta file (required)                     | `/path/to/data/genome.fasta`                  |
| `annotation`       | Path to the reference transcriptome .gtf file (required)      | `/path/to/data/transcriptome.gtf`             |
| `oriented`         | Orientation of reads based on library protocol (required)     | `false`                                       |
| `sam`              | Path to sam files after eoulsan (required if oriented=true)   | `null`                                        |

### Tools Parameters

Configuration of tools used for annotation process:

| Parameter          | Description                                                   | Default Value                                 |
|--------------------|---------------------------------------------------------------|-----------------------------------------------|
| `config`           | Path to Restrander configuration file (TSO and RTP sequences) (required if reads are non oriented)    | `"${projectDir}/assets/PCB111.json`   |
| `intron_length`    | Parameter for maximum intron length for Minimap2              | `20000`                                       |
| `junc_bed`         | Parameter for junction bed annotation for Minimap2            | null                                          |
| `model_strategy`   | Parameter for IsoQuant transcript model construction          | `default_ont`                                 |
| `novel_mono_exonic`| Parameter for IsoQuant transcript model construction          | `true`                                        |
| `optional_shortread`       | Path to Illumina shortreads .fasta file for RNA-Bloom      | `null`                                   |
| `gffread_parameters` |  Parameter for gffread clustering                           | `-M`                                          |

### Additional Parameters

| Parameter          | Description                                                   | Default Value                                 |
|--------------------|---------------------------------------------------------------|-----------------------------------------------|
| `outdir`           | Output directory for results                                  | `"result"`                                    |

### Run Parameters

Configuration for running the workflow:

| Parameter         | Description                        | Default Value             |
|-------------------|------------------------------------|---------------------------|
| `threads`         | Number of threads to use           | `4`                       |
| `docker.runOptions` | Docker run options to use        | `'-u $(id -u):$(id -g)'`  |


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
