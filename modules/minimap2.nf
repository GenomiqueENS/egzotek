/*
========================================================================================
   MINIMAP2 module
========================================================================================
*/

/*
* Transcript genome alignment
*/

process MINIMAP2 {
   // where to store the results and in which way
      maxForks 1
      label 'process_high'
      
      publishDir( "${params.outdir}/sam", mode: 'copy' )

      // show in the log which input file is analysed
      tag( "${fasta}" )
      
      input:
      val ready
      path genome
      path fasta
      val intron_length
      path junc_bed
      
      output:
      path( "${fasta.SimpleName}.sam" ), emit: isoquant_sam
      
      script:
      def junc_bed_arg = junc_bed.name != 'no_junc_bed' ? "--junc-bed $junc_bed" : ""
      """
      minimap2 -G ${intron_length} -ax splice --secondary=no -uf -k14 ${junc_bed_arg} ${genome} ${fasta} >  ${fasta.SimpleName}.sam
      """
}