/*
========================================================================================
   ISOQUANT module
========================================================================================
*/

/*
* Create Isoquant trancript model
*/

process ISOQUANT {
   debug true
   label 'MEDIUM_MEM_TASK'
   maxForks 1

   // where to store the results and in which way
   publishDir( "${params.outdir}", mode: 'link' )

   // show in the log which input file is analysed
   debug true
   tag( "${samplesheet}" )

   input:
   val ready
   path bams
   path genome 
   path samplesheet
   val model_strategy

   output:
   path( "isoquant/*/*.transcript_models.gtf" ), emit: isoquant_gtf
   path( "isoquant/*/*" ), emit: isoquant_counts
   
   script:
   """
   isoquant.py --reference ${genome}               \
   --yaml ${samplesheet}                           \
   --data_type nanopore                            \
   --clean_start                                   \
   --stranded forward                              \
   --model_construction_strategy ${model_strategy} \
   --threads ${task.cpus}                          \
   --output isoquant > isoquant.out 2> isoquant.err
   """
}

process ISOQUANT_CONDITION {

   // show in the log which input file is analysed
   debug true
   tag( "${isoquant_gtf}" )

   input:
   path isoquant_gtf 

   output:
   tuple val(condition), path( "${isoquant_gtf}" ), emit: isoquant_condition_gtf
   
   script:
   condition= isoquant_gtf.SimpleName.split('_')[0]
   """
   """
}
