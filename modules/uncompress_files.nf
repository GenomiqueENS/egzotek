/*
========================================================================================
   UNCOMPRESS modules
========================================================================================
*/

process UNCOMPRESS_GENOME {
   debug true
   publishDir( "${params.outdir}/ressources", mode: 'copy' )

   tag( "${genome}" )

   input:
   path genome

   output:
   path( "${genome.BaseName}" ), emit: genome_isoquant
   path( "${genome.BaseName}" ), emit: genome_gffread
   
   script:
   """
   bzip2 -dc ${genome} > ${genome.BaseName}
   """
}