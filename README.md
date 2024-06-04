# Egzotek
Egzotek is a bioinformatic pipeline designed for transcript annotation of non-model species with incomplete or poorly annotated genomes. It is developed to build a consensus annotated genome usig long RNA reads. 

1. Read orientation (eoulsan)
2. Transcript annotation (rna-bloom)
  i.   optional short-read polishing 
3. Genome mapping (minimap2)
4. Bam to bed file conversion (paftools)
5. Bed to gff file conversion (agat)
6. gff to gtf file conversion (agat)
7. sam to bam file conversion (samtools)
8. transcript annotation (isoquant)
9. complement annotation (agat)
10. clusterisation (gffread)
