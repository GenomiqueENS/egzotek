/*
========================================================================================
   SAMTOOLS module
========================================================================================
*/

/*
* Convert SAM files to BAM files
*/

process SAMTOOLS {
   debug true

   // where to store the results and in which way
   publishDir( "${params.outdir}/bam", mode: 'link' )

   // show in the log which input file is analysed
   tag( "${sam}" )

   input:
   path(sam)

   output:
   tuple path("${sam.SimpleName}.bam"), path("${sam.SimpleName}.bam.bai"), emit: samtools_bam
   val("process_complete"), emit: process_control
      
   script:
   """
   samtools view -Sb -o ${sam.SimpleName}.bam ${sam}
   samtools sort -O bam -o ${sam.SimpleName}.bam ${sam.SimpleName}.bam
   samtools index ${sam.SimpleName}.bam
   """
}  

