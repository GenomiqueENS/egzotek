/*
========================================================================================
   Annotation Nextflow Workflow
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
   Pipeline Modules
========================================================================================
*/

include { read_conf; get_path; get_genome_desc; create_channel_from_path; UNCOMPRESS } from './modules/common.nf'
include { EOULSAN_READ_FILTER_SR } from './modules/filterreads.nf'
include { EOULSAN_INDEX } from './modules/mapping.nf'
include { EOULSAN_MAPPING } from './modules/mapping.nf'
include { EOULSAN_SAM_FILTER } from './modules/filtersam.nf'
include { EOULSAN_EXPRESSION } from './modules/expression.nf'
include { GFFREAD } from './modules/gffread.nf'
include { ISOQUANT } from './modules/isoquant.nf'
include { MINIMAP2 } from './modules/minimap2.nf'
include { MERGE_ANNOTATION } from './modules/merge_annotation.nf'
include { MERGE_FASTQ } from './modules/merge_fastq.nf'
include { RESTRANDER } from './modules/restrander.nf'
include { RNA_BLOOM } from './modules/rnabloom.nf'
include { RNABLOOM_MINIMAP2 } from './modules/rnabloom_minimap2.nf'
include { RNABLOOM_PAFTOOLS } from './modules/rnabloom_paftools.nf'
include { RNABLOOM_AGAT_BED2GFF; RNABLOOM_AGAT_GFF2GTF; AGAT_COMPLEMENT; MERGE_AGAT_GFF2GTF } from './modules/agat.nf'
include { SAMTOOLS } from './modules/samtools.nf'
include { SAMTOOLS_MERGE } from './modules/samtools_merge.nf'

/*
========================================================================================
   Create Channels
========================================================================================
*/
genome_ch = file( params.genome )
annot_ch = Channel.of( params.annotation )
config_ch = file( params.config, checkIfExists:true )
reads_ch = Channel.fromPath( params.reads, checkIfExists:true )
// channel for optional short reads
shortread_ch = params.optional_shortread != null ? file(params.optional_shortread, type: "file") : file("no_shortread", type: "file")

/*
========================================================================================
   WORKFLOW - Transcript Annotation
========================================================================================
*/

workflow {
  // Index creation
   RESTRANDER(reads_ch, config_ch)

   // Transcript annotation modules: Isoquant 
   MINIMAP2(genome_ch, RESTRANDER.out.restrander_fastq, params.intron_length)
   SAMTOOLS(MINIMAP2.out.isoquant_sam)
   SAMTOOLS_MERGE(SAMTOOLS.out.samtools_bam.collect())
   ISOQUANT(genome_ch, SAMTOOLS_MERGE.out.samtools_mergedbam, params.model_strategy)

   // Transcript annotation modules: RNABloom 
   MERGE_FASTQ(RESTRANDER.out.restrander_fastq.collect())
   RNA_BLOOM(MERGE_FASTQ.out.merged_fastq, shortread_ch)
   RNABLOOM_MINIMAP2(genome_ch, RNA_BLOOM.out.rnabloom_fasta)
   RNABLOOM_PAFTOOLS(RNABLOOM_MINIMAP2.out.rnabloom_sam)
   RNABLOOM_AGAT_BED2GFF(RNABLOOM_PAFTOOLS.out.rnabloom_bed)
   RNABLOOM_AGAT_GFF2GTF(RNABLOOM_AGAT_BED2GFF.out.agat_gff)

   // Merging of transcript annotations
   AGAT_COMPLEMENT(ISOQUANT.out.isoquant_gtf, RNABLOOM_AGAT_GFF2GTF.out.agat_gtf)
   GFFREAD(genome_ch, AGAT_COMPLEMENT.out.polished_gtf)
   MERGE_AGAT_GFF2GTF(GFFREAD.out.gffread_gff3)
   MERGE_ANNOTATION(annot_ch, MERGE_AGAT_GFF2GTF.out.merged_agat_gtf)


   // if (params.oriented == false) {
   //      RESTRANDER(reads_ch, config_ch) 
   //      }
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