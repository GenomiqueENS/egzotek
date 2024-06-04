# Egzotek
Egzotek is a bioinformatic pipeline designed for transcript annotation of non-model species with incomplete or poorly annotated genomes. It is developed to build a consensus annotated genome usig long RNA reads. 

1. Read orientation ([eoulsan](https://github.com/GenomiqueENS/eoulsan))
2. Transcript annotation ([rna-bloom](https://github.com/bcgsc/RNA-Bloom))
  * optional short-read polishing 
3. Genome mapping ([minimap2](https://github.com/lh3/minimap2))
4. Bam to bed file conversion ([minimap2-paftools](https://github.com/lh3/minimap2))
5. Bed to gff file conversion ([agat](https://github.com/NBISweden/AGAT))
6. gff to gtf file conversion ([agat](https://github.com/NBISweden/AGAT))
7. sam to bam file conversion ([samtools](https://github.com/samtools/samtools))
8. transcript annotation ([isoquant](https://github.com/ablab/IsoQuant))
9. complement annotation ([agat](https://github.com/NBISweden/AGAT))
10. clusterisation ([gffread](https://github.com/gpertea/gffread))
