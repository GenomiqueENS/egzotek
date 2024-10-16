/*
========================================================================================
   Transcript Annotation Nextflow Workflow
========================================================================================
   Github   :
   Contact  :
----------------------------------------------------------------------------------------
*/

nextflow.enable.dsl=2

// Display pipeline details
println """\
      T R A N S C R I P T - A N N O T A T I O N - N F   P I P E L I N E
      ===================================
      genome      : ${params.genome}
      fastq       : ${params.reads}
      outdir      : ${params.outdir}
      """
      .stripIndent()

/*
========================================================================================
   Pipeline Subworklows
========================================================================================
*/
include { ORIENTED_WORKFLOW          } from './subworkflows/oriented_annotation'
include { NONORIENTED_WORKFLOW       } from './subworkflows/nonoriented_annotation'

/*
========================================================================================
   WORKFLOW - Transcript Annotation
========================================================================================
*/

workflow{
   genome_ch = file( params.genome )
   annot_ch = file( params.annotation )
   config_ch = file( params.config, checkIfExists:true )
   shortread_ch = params.optional_shortread != null ? file(params.optional_shortread, type: "file") : file("no_shortread", type: "file")
   junc_bed_ch = params.junc_bed != null ? file(params.junc_bed, type: "file") : file("no_junc_bed", type: "file")
   samplesheet_ch = Channel.fromPath( params.samplesheet, checkIfExists:true )
   
   if (params.oriented == false) {
      reads_ch = Channel.fromPath( params.reads, checkIfExists:true )
      
      NONORIENTED_WORKFLOW(genome_ch,
                        annot_ch,
                        config_ch,
                        shortread_ch,
                        junc_bed_ch,
                        samplesheet_ch,
                        reads_ch)
   } else if (params.oriented == true) {
      sam_ch = Channel.fromPath( params.sam, checkIfExists:true )

      ORIENTED_WORKFLOW(genome_ch,
                        annot_ch,
                        config_ch,
                        shortread_ch,
                        junc_bed_ch,
                        samplesheet_ch,
                        sam_ch)
   }
}

// Display pipeline execution summary upon completion
workflow.onComplete {
   println (workflow.success ? """
      Pipeline execution summary
      ---------------------------
      Completed at: ${workflow.complete}
      Duration    : ${workflow.duration}
      Success     : ${workflow.success}
      workDir     : ${workflow.workDir}
      exit status : ${workflow.exitStatus}
      """ : """
      Failed      : ${workflow.errorReport}
      exit status : ${workflow.exitStatus}
      """
   )
}

/*
========================================================================================
   THE END
========================================================================================
*/