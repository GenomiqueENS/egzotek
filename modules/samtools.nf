/*
========================================================================================
   SAMTOOLS module
========================================================================================
*/

// Parameter definitions
params.OUTPUT = "result/isoquant"

/*
* Convert SAM files to BAM files
*/

process SAMTOOLS {

   // where to store the results and in which way
   publishDir( params.OUTPUT, mode: 'copy' )

   // show in the log which input file is analysed
   tag( "${sam}" )

   input:
   path(sam)

   output:
   path("*.bam"), emit: samtools_bam
   path("*.bam.bai")
      
   script:
   """
   samtools view -Sb -o ${sam.SimpleName}.bam ${sam}
   samtools sort -O bam -o ${sam.SimpleName}.bam ${sam.SimpleName}.bam
   samtools index ${sam.SimpleName}.bam
   """
}  

