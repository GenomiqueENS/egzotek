/*
========================================================================================
   RNABLOOM module
========================================================================================
*/
params.OUTPUT = "result/rnabloom"

/*
* RNA Bloom Transcript Model
*/
process RNA_BLOOM {
   // where to store the results and in which way
   debug true
   cpus 24
   publishDir( params.OUTPUT, mode: 'copy' )

   // show in the log which input file is analysed
   tag( "RNA-Bloom ${longread}" )

   input:
   path longread 
   path shortread

   output:
   path( "rnabloom_assembly/*.transcripts.fa" ), emit: rnabloom_fasta
   path( "rnabloom_assembly/*" )
   
   script:
   // argument for optional shortreads channel
   def shortread_arg = shortread.name != 'no_shortread' ? "-ser $shortread" : ""
   """
   rnabloom    \
   -long ${longread} \
   -stranded    \
   ${shortread_arg} \
   -t 12
   """
}  
