/*
========================================================================================
   ISOQUANT module
========================================================================================
*/

/*
* Create Isoquant trancript model
*/

process ISOQUANT {

   // where to store the results and in which way
   label 'process_high'
   maxForks 1
   
   publishDir( "${params.outdir}", mode: 'copy' )

   // show in the log which input file is analysed
   debug true
   tag( "${samplesheet}" )

   input:
   val ready
   path bams
   path genome 
   path samplesheet
   val model_strategy
   val novel_mono_exonic

   output:
   path( "isoquant/*/*_isoquant.gtf" ), emit: isoquant_gtf
   path( "isoquant/*/*" ), emit: isoquant_counts
   
   script:
   """
   isoquant.py --reference ${genome}               \
   --yaml ${samplesheet}                           \
   --data_type nanopore                            \
   --clean_start                                   \
   --stranded forward                              \
   --model_construction_strategy ${model_strategy} \
   --report_novel_unspliced ${novel_mono_exonic}   \
   -t $task.cpus                                   \
   -o isoquant \
   && for file in isoquant/*/*.transcript_models.gtf; do cp "\$file" "\${file%.transcript_models.gtf}_isoquant.gtf"; done
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
