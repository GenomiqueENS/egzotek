/*
========================================================================================
   MINIMAP2 module
========================================================================================
*/

// Parameter definitions
params.OUTPUT = "result/isoquant"

/*
* Transcript genome alignment
*/

process MINIMAP2 {
   // where to store the results and in which way
      debug true
      maxForks 1
      cpus 14
      publishDir( params.OUTPUT, mode: 'copy' )

      // show in the log which input file is analysed
      tag( "${fasta}" )
      
      input:
      path genome
      path fasta 
      
      output:
      path( "*.sam" ), emit: isoquant_sam
      
      script:
      """
      minimap2 -ax splice -uf -k14 \
      ${genome} ${fasta} >  ${fasta.SimpleName}.sam
      """
}