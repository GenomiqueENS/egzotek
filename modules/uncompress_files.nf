/*
========================================================================================
   UNCOMPRESS modules
========================================================================================
*/

process UNCOMPRESS_GENOME {
   debug true

   // where to store the results and in which way
   publishDir( "${params.outdir}/ressources", mode: 'link' )

   tag( "${genome}" )

   input:
   path genome

   output:
   path( "${genome.BaseName}" ), emit: genome_isoquant
   path( "${genome.BaseName}" ), emit: genome_minimap2
   path( "${genome.BaseName}" ), emit: genome_gffread
   
   script:
   """
   bzip2 -dc ${genome} > ${genome.BaseName}
   """
}