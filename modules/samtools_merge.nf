/*
========================================================================================
   SAMTOOLS_MERGE module
========================================================================================
*/

// Parameter definitions
params.OUTPUT = "result/isoquant"

/*
* Convert SAM files to BAM files
*/

process SAMTOOLS_MERGE {

   // where to store the results and in which way
   publishDir( params.OUTPUT, mode: 'copy' )

   // show in the log which input file is analysed
   debug true
   tag( "${bam}" )

   input:
   path(bam)

   output:
   tuple path("merged.bam"), path("merged.bam.bai"), emit: samtools_mergedbam
      
   script:
   """
   samtools merge -o all.bam *.bam
   samtools sort -O bam -o merged.bam all.bam
   samtools index merged.bam
   """
} 
