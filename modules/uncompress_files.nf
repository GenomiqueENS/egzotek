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
   path( "*" ), emit: genome_isoquant
   path( "*" ), emit: genome_gffread
   
   script:
   """
   bzip2 -dc ${genome} > ${genome.BaseName}
   """
}

process UNCOMPRESS_ANNOTATION {
   debug true
   publishDir( "${params.outdir}/ressources", mode: 'copy' )

   input:
   path annotation

   output:
   path( "*" ), emit: annotation_merge
   
   script:
   """
   bzip2 -dk ${annotation}
   """
}