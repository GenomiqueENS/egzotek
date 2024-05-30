/*
========================================================================================
   PAFTOOLS module
========================================================================================
*/

// Parameter definitions
params.OUTPUT = "result/rnabloom"

/*
* Pathtools Conversion sam > bed
*/

process RNABLOOM_PAFTOOLS {
   // where to store the results and in which way
   debug true
   publishDir( params.OUTPUT, mode: 'copy' )

   // show in the log which input file is analysed
   tag( "${bloomsam}" )
   
   input:
   path bloomsam 
   
   output:
   path( "rnabloom_aln.bed" ), emit: rnabloom_bed
   
   script:
   """
   paftools.js splice2bed ${bloomsam} > rnabloom_aln.bed
   """

}
