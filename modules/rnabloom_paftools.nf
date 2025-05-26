/*
========================================================================================
   PAFTOOLS module
========================================================================================
*/

/*
* Pathtools Conversion sam > bed
*/

process RNABLOOM_PAFTOOLS {
   debug true

   // where to store the results and in which way
   debug true
   publishDir( "${params.outdir}/rnabloom", mode: 'link' )

   // show in the log which input file is analysed
   tag( "${bloomsam}" )
   
   input:
   tuple val(condition), path(bloomsam)
   
   output:
   tuple val(condition), path( "${bloomsam.SimpleName}.bed" ), emit: rnabloom_bed
   
   script:
   """
   paftools.js splice2bed ${bloomsam} > ${bloomsam.SimpleName}.bed
   """

}
