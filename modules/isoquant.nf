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
   tag( "${samplesheet}" )

   input:
   path genome 
   path samplesheet
   val(model_strategy)

   output:
   path( "result/isoquant/OUT/*.gtf" ), emit: isoquant_gtf
   path( "result/isoquant/OUT/*" ), emit: isoquant_counts
   
   script:   
   """
   isoquant.py --reference ${genome}               \
   --yaml ${samplesheet}                                    \
   --data_type nanopore                            \
   --clean_start                                   \
   --stranded forward                              \
   --model_construction_strategy ${model_strategy} \
   -t 12                                           \
   -o ${params.OUTPUT}
   """
}  


