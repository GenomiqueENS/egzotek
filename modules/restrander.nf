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
   tag( "${fastq}" )

   input:
   path fastq 
   path config

   output:
   path( "${fastq.SimpleName}.fastq.gz" ), emit: restrander_fastq
   val(params.OUTPUT), emit: restrander_output_dir
   val("process_complete"), emit: process_control 

   script:
   """
   /usr/local/restrander/restrander ${fastq} \
   ${fastq.SimpleName}.fastq.gz  \
   ${config}
   """
}  


