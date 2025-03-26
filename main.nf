#!/usr/bin/env nextflow
/*
========================================================================================
   Egzotek: A transcript annotation Nextflow workflow
========================================================================================
   Github   : https://github.com/GenomiqueENS/egzotek
   Contact  :
----------------------------------------------------------------------------------------
*/

nextflow.enable.dsl=2

params.help = false

if ( params.help) {
   help = """
   Usage:
      nextflow run main.nf --reads <path> --samplesheet <path> [options]

   Description:
      EGZOTEK - TRANSCRIPTOME ANNOTATION PIPELINE USING NANOPORE READS
      Builds transcriptome annotations from nanopore data

      Required parameters:
            --reads <path>                   Path to fastq nanopore reads.
            --samplesheet <path>	            Path to the samplesheet file
            --genome <path>	               Path to the genome file
            --annotation <path>          	   Path to the reference transcriptome file
            --orientation <value>            Orientation of reads based on library protocol
            --sam <path>                     Path to sam files after eoulsan (required if oriented=true)
            --config <path> 	               Path to Restrander configuration file (required if oriented=false)

      Optional arguments:
            --intron_length <value>	         Parameter for maximum intron length for Minimap2
            --junc_bed <path>	               Parameter for junction bed annotation for Minimap2
            --model_strategy <value>	      Parameter for transcript model construction algorithm
            --optional_shortread <path>	   Path to Illumina reads for short-read polishing in RNA-Bloom

            -w       The NextFlow work directory. Delete the directory once the process
                     is finished [default: ${workDir}]""".stripMargin()
    // Print the help with the stripped margin and exit
   println(help)
   exit(0)
}


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

   assert params.reads : "No reads specified. Please provide reads with --reads"
   assert params.samplesheet : "No samplesheet specified. Please provide a samplesheet with --samplesheet"
   assert params.annotation : "No GFF3 annotation specified. Please provide reads with --annotation"

   annot_file = file( params.annotation, checkIfExists:true )
   config_file = file( params.config, checkIfExists:true )
   shortread_file = params.optional_shortread != null ? file(params.optional_shortread, type: "file") : file("no_shortread", type: "file")
   junc_bed_file = params.junc_bed != null ? file(params.junc_bed, type: "file") : file("no_junc_bed", type: "file")
   samplesheet_ch = Channel.fromPath( params.samplesheet, checkIfExists:true )
   reads_ch = Channel.fromPath( params.reads, checkIfExists:true )

   if (params.oriented == false) {
      
      assert params.genome : "No genome specified. Please provide reads with --genome"
      genome_file = file( params.genome, checkIfExists:true )

      NONORIENTED_WORKFLOW(genome_file
                           annot_file,
                           config_file,
                           shortread_file,
                           junc_bed_file,
                           samplesheet_ch,
                           reads_ch)
   } else if (params.oriented == true) {
      
      assert params.sam : "No alignments specified. Please provide reads with --sam"
      sam_ch = Channel.fromPath( params.sam, checkIfExists:true )

      ORIENTED_WORKFLOW(annot_file,
                        config_file,
                        shortread_file,
                        junc_bed_file,
                        samplesheet_ch,
                        sam_ch,
                        reads_ch)
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

log.info """\
   EGZOTEK - TRANSCRIPTOME ANNOTATION PIPELINE USING NANOPORE READS
   ===================================
   nanopore reads                        : ${params.reads}
   samplesheet                           : ${params.samplesheet}
   genome                                : ${params.genome}
   annotation                            : ${params.annotation}
   orientation                           : ${params.oriented}
   eoulsan sam files                     : ${params.sam}
   restrander config file                : ${params.config}
   intron length minimap2                : ${params.intron_length}
   junction bed files minimap2           : ${params.junc_bed}
   IsoQuant model strategy               : ${params.model_strategy}
   RNABloom short read polishing data    : ${params.optional_shortread}
   gffread parameters                    : ${params.gffread_parameters}
   outdir                                : ${params.outdir}
   """
   .stripIndent()

/*
========================================================================================
*/
