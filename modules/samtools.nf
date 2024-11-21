/*
========================================================================================
   SAMTOOLS module
========================================================================================
*/

/*
* Convert SAM files to BAM files
*/

process SAMTOOLS {
   label 'process_high'
   publishDir( "${params.outdir}/bam", mode: 'copy' )
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

