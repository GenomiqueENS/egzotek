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