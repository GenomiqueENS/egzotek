/*
========================================================================================
   MERGE_FASTQ module
========================================================================================
*/
params.OUTPUT = "result/rnabloom"

/*
* Merge Fast
*/
process MERGE_FASTQ_RESTRANDER {
   // where to store the results and in which way
   debug true
   publishDir( params.OUTPUT, mode: 'copy' )

   input:
   path samplesheet
   val restrander_dir
   val ready

   output:
   path( "*.fastq" ), emit: merged_fastq
   
   script:
   """
   python3 $projectDir/bin/merge_fastq.py ${samplesheet} $projectDir/${restrander_dir}/
   """
}

process MERGE_FASTQ_EOULSAN {
   // where to store the results and in which way
   debug true
   publishDir( params.OUTPUT, mode: 'copy' )

   input:
   path samplesheet

   output:
   path( "*.fastq" ), emit: merged_fastq
   
   script:
   def base_path = params.reads.substring(0, params.reads.lastIndexOf('/'))  
   """
   python3 $projectDir/bin/merge_fastq.py ${samplesheet} ${base_path}
   """
}