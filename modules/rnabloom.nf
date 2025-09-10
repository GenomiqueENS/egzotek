/*
========================================================================================
   RNABLOOM module
========================================================================================
*/

/*
* RNA Bloom Transcript Model
*/
process RNA_BLOOM {
   debug true
   label 'HIGH_MEM_TASK'
   maxForks 1
   
   // where to store the results and in which way
   publishDir ("${params.outdir}/rnabloom", mode: 'link')

   // show in the log which input file is analysed
   tag( "${longread}" )

   input:
   path longread 
   path shortread

   output:
   tuple val(condition), path("${longread.SimpleName}/rnabloom.transcripts.fa" ), emit: rnabloom_fasta
   path( "${longread.SimpleName}/*" )
   
   script:
   // argument for optional shortreads channel
   def shortread_arg = shortread.name != 'no_shortread' ? "-ser $shortread" : ""
   condition = longread.SimpleName
   """
   java \
   -XX:MaxRAMPercentage=65.0 \
   -jar /usr/local/lib/rnabloom-v*.jar \
     -long ${longread} \
     -stranded    \
     ${shortread_arg} \
     -t ${task.cpus} \
     -outdir ${longread.SimpleName} \
     > rnabloom.out 2> rnabloom.err
   """
}  
