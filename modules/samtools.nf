/*
========================================================================================
   SAMTOOLS module
========================================================================================
*/

/*
* Convert SAM files to BAM files
*/

process SAMTOOLS {

   // where to store the results and in which way
   publishDir( "${params.outdir}/bam", mode: 'copy' )

   // show in the log which input file is analysed
   tag( "${sam}" )

   input:
   path(sam)

   output:
   path("${sam.SimpleName}.bam"), emit: samtools_bam
   path("${sam.SimpleName}.bam.bai")
   val("process_complete"), emit: process_control
      
   script:
   """
   samtools view -Sb -o ${sam.SimpleName}.bam ${sam}
   samtools sort -O bam -o ${sam.SimpleName}.bam ${sam.SimpleName}.bam
   samtools index ${sam.SimpleName}.bam
   """
}  

