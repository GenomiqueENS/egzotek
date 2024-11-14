/*
========================================================================================
   RNABLOOM module
========================================================================================
*/

/*
* RNA Bloom Transcript Model
*/
process RNA_BLOOM {
   // where to store the results and in which way
   debug true
   cpus 16
   maxForks 1
   maxRetries 2
   
   publishDir ("${params.outdir}/rnabloom", mode: 'copy')

   // show in the log which input file is analysed
   tag( "RNA-Bloom ${longread}" )

   input:
   path longread 
   path shortread

   output:
   tuple val(condition), path("${longread.SimpleName}/${longread.SimpleName}.fa" ), emit: rnabloom_fasta
   path( "${longread.SimpleName}/*" )
   
   script:
   // argument for optional shortreads channel
   def shortread_arg = shortread.name != 'no_shortread' ? "-ser $shortread" : ""
   condition = longread.SimpleName
   """
   rnabloom    \
   -long ${longread} \
   -stranded    \
   ${shortread_arg} \
   -t 12 \
   -outdir ${longread.SimpleName} \
   && cp  ${longread.SimpleName}/rnabloom.transcripts.fa ${longread.SimpleName}/${longread.SimpleName}.fa
   """
}  
