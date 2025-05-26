/*
========================================================================================
   RESTRANDER module
========================================================================================
*/

process RESTRANDER {
   debug true

   // where to store the results and in which way
   publishDir( "${params.outdir}/restrander", mode: 'link' )

   // show in the log which input file is analysed
   debug true
   tag( "${fastq}" )

   input:
   path fastq 
   path config

   output:
   path( "${fastq.SimpleName}.fastq.gz" ), emit: restrander_fastq
   path( "${fastq.SimpleName}.json" ), emit: restrander_stats

   script:
   """
   /usr/local/restrander/restrander ${fastq} \
   ${fastq.SimpleName}-restrander.fastq.gz  \
   ${config} > ${fastq.SimpleName}.json && \
   mv ${fastq.SimpleName}-restrander.fastq.gz ${fastq.SimpleName}.fastq.gz
   """
}
