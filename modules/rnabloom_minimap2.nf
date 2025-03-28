/*
========================================================================================
   RNABLOOM_MINIMAP2 module
========================================================================================
*/

/*
* Transcript genome alignment
*/

process RNABLOOM_MINIMAP2 {
   // where to store the results and in which way
   debug true
   maxForks 1
   cpus 24
   publishDir( "${params.outdir}/rnabloom", mode: 'link' )

   // show in the log which input file is analysed
   tag( "${bloomfasta}" )
   
   input:
   path genome
   tuple val(condition), path(bloomfasta)
   val intron_length
   path junc_bed
   
   output:
   tuple val(condition), path( "${bloomfasta.SimpleName}.sam" ), emit: rnabloom_sam
   
   script:
   def junc_bed_arg = junc_bed.name != 'no_junc_bed' ? "--junc-bed $junc_bed" : ""
   """
   minimap2 -G ${intron_length} -ax splice -uf -k14 \
   ${junc_bed_arg} ${genome} ${bloomfasta} > ${bloomfasta.SimpleName}.sam
   """

}
