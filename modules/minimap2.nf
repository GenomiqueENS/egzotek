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
      debug true
      maxForks 1
      cpus 14
      publishDir( "${params.outdir}/sam", mode: 'link' )

      // show in the log which input file is analysed
      tag( "${fasta}" )
      
      input:
      path genome
      path fasta
      val intron_length
      path junc_bed
      
      output:
      path( "${fasta.SimpleName}.sam" ), emit: isoquant_sam
      
      script:
      def junc_bed_arg = junc_bed.name != 'no_junc_bed' ? "--junc-bed $junc_bed" : ""
      """
      minimap2 -t ${task.cpus} -G ${intron_length} -ax splice --secondary=no -uf -k14 ${junc_bed_arg} ${genome} ${fasta} >  ${fasta.SimpleName}.sam
      """
}