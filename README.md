# Egzotek
Egzotek is a bioinformatic pipeline designed for transcript annotation of non-model species with incomplete or poorly annotated genomes. It is developed to build a consensus annotated genome usig long RNA reads. 

![transcriptannotation_wf](https://github.com/GenomiqueENS/egzotek/blob/main/transcript_annotation_wf.jpg)


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


