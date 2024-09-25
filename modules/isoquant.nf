/*
========================================================================================
   ISOQUANT module
========================================================================================
*/

// Parameter definitions
params.OUTPUT = "result/isoquant"

/*
* Create Isoquant trancript model
*/

process ISOQUANT {

   // where to store the results and in which way
   cpus 24
   publishDir( params.OUTPUT, mode: 'copy' )

   // show in the log which input file is analysed
   debug true
   tag( "${bam}" )

   input:
   path genome 
   tuple path(bam), path(bai)
   val(model_strategy)

   output:
   path( "result/isoquant/OUT/*.gtf" ), emit: isoquant_gtf
   path( "result/isoquant/OUT/*" ), emit: isoquant_counts
   
   script:   
   """
   isoquant.py --reference ${genome}               \
   --bam ${bam}                                    \
   --data_type nanopore                            \
   --clean_start                                   \
   --stranded forward                              \
   --model_construction_strategy ${model_strategy} \
   -t 12                                           \
   -o ${params.OUTPUT}
   """
}  


