/*
========================================================================================
   RESTRANDER module
========================================================================================
*/

// Parameter definitions
params.OUTPUT = "result/restrander"

/*
* Create Isoquant trancript model
*/

process RESTRANDER {

   // where to store the results and in which way
   publishDir( params.OUTPUT, mode: 'copy' )

   // show in the log which input file is analysed
   debug true
   tag( "${bam}" )

   input:
   path fastq 
   path config

   output:
   path( "result/restrander/*_restrander.fastq.gz" ), emit: restrander_fastq

   script:
   """
   restrander/restrander ${fastq} \
   ${fastq.SimpleName}_restrander.fastq.gz
   ${config}
   """
}  


