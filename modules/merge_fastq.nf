/*
========================================================================================
   MERGE_FASTQ module
========================================================================================

/*
* Merge Fast
*/
process MERGE_FASTQ_RESTRANDER {
   // where to store the results and in which way
   debug true
   publishDir( "${params.outdir}/rnabloom", mode: 'link' )
   
   tag( "${reads}" )

   input:
   path samplesheet
   path reads
   val ready

   output:
   path( "*.fastq" ), emit: merged_fastq
   
   script:
   """
   python3 $projectDir/bin/merge_fastq.py ${samplesheet}
   """
}

process MERGE_FASTQ_EOULSAN {
   // where to store the results and in which way
   debug true
   publishDir( "${params.outdir}/rnabloom", mode: 'link' )
   
   tag( "${reads}" )

   input:
   path samplesheet
   path reads

   output:
   path( "*.fastq" ), emit: merged_fastq
   
   script:
   """
   python3 $projectDir/bin/merge_fastq.py ${samplesheet}
   """
}