/*
========================================================================================
   MERGE_FASTQ module
========================================================================================
*/
params.OUTPUT = "result/rnabloom"

/*
* Merge Fast
*/
process MERGE_FASTQ {
   // where to store the results and in which way
   debug true
   publishDir( params.OUTPUT, mode: 'copy' )

   // show in the log which input file is analysed
   tag( "Merge fastq ${filtered_fastq}" )

   input:
   path filtered_fastq 

   output:
   path( "merged_filtered.fastq" ), emit: merged_fastq
   
   script:
   """
   cat ${filtered_fastq} >> merged_filtered.fastq
   """
}  
