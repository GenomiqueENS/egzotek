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

include { read_conf; get_path; get_genome_desc; create_channel_from_path; UNCOMPRESS }          from './modules/common.nf'
include { EOULSAN_READ_FILTER_SR }                                                              from './modules/filterreads.nf'
include { EOULSAN_INDEX }                                                                       from './modules/mapping.nf'
include { EOULSAN_MAPPING }                                                                     from './modules/mapping.nf'
include { EOULSAN_SAM_FILTER }                                                                  from './modules/filtersam.nf'
include { EOULSAN_EXPRESSION }                                                                  from './modules/expression.nf'
include { GFFREAD }                                                                             from './modules/gffread.nf' 
include { ISOQUANT }                                                                            from './modules/isoquant.nf'
include { MINIMAP2 }                                                                            from './modules/minimap2.nf'
include { MERGE_ANNOTATION }                                                                    from './modules/merge_annotation.nf'
include { MERGE_FASTQ }                                                                         from './modules/merge_fastq.nf'
include { RESTRANDER }                                                                          from './modules/restrander.nf'
include { RNA_BLOOM }                                                                           from './modules/rnabloom.nf'
include { RNABLOOM_MINIMAP2 }                                                                   from './modules/rnabloom_minimap2.nf'
include { RNABLOOM_PAFTOOLS }                                                                   from './modules/rnabloom_paftools.nf'
include { RNABLOOM_AGAT_BED2GFF; RNABLOOM_AGAT_GFF2GTF; AGAT_COMPLEMENT; MERGE_AGAT_GFF2GTF }   from './modules/agat.nf'
include { SAMPLESHEET2YAML }                                                                    from './modules/samplesheet2yaml.nf'
include { SAMTOOLS }                                                                            from './modules/samtools.nf'
include { SAMTOOLS_MERGE }                                                                      from './modules/samtools_merge.nf'
/*
========================================================================================
   Create Channels
======================================================================================== 
*/
genome_ch = file( params.genome )
annot_ch = Channel.of( params.annotation )
config_ch = file( params.config, checkIfExists:true )
reads_ch = Channel.fromPath( params.reads, checkIfExists:true )
shortread_ch = params.optional_shortread != null ? file(params.optional_shortread, type: "file") : file("no_shortread", type: "file")
junc_bed_ch = params.junc_bed != null ? file(params.junc_bed, type: "file") : file("no_junc_bed", type: "file")
samplesheet_ch = Channel.fromPath( params.samplesheet, checkIfExists:true )

params.eoulsan_genome = "genome://hg19ens105"
params.eoulsan_annotation = "gtf://hg19ens105"
params.mapperName = "minimap2"
params.mapperVersion = "2.24"
params.mapperFlavor = ""
params.indexerArguments = "-x splice"
params.mappersArguments = "-x splice --eqx --secondary=no --junc-bed /import/rhodos10/ressources/sequencages/bed12/only_chr_Homo_sapiens_ens105.bed"
params.tmpDir = projectDir + "/tmp"
params.binaryDir = "/tmp"
params.storages = read_conf()
params.readFilteringConf = [ "trimpolynend" : "" ]
params.samFilteringConf = [ "removeunmapped" : "true", "quality.threshold" : "1", "removesupplementary": "true", "removemultimatches" : "true" ]
params.expressionConf = [ "genomic.type" : "exon", "attribute.id" : "gene_id", "stranded" : "no", "overlap.mode" : "union", "remove.ambiguous.cases" : "false" ]
/*
========================================================================================
   WORKFLOW - Transcript Annotation
========================================================================================
*/

workflow{
   if (params.oriented == false) {
      RESTRANDER(reads_ch, config_ch)

      // Transcript annotation modules: Isoquant
      MINIMAP2(genome_ch, RESTRANDER.out.restrander_fastq, params.intron_length, junc_bed_ch)
      SAMTOOLS(MINIMAP2.out.isoquant_sam)
      //SAMTOOLS_MERGE(SAMTOOLS.out.samtools_bam.collect())
      SAMPLESHEET2YAML(samplesheet_ch)
      ISOQUANT(SAMTOOLS.out.process_control.collect(), genome_ch, SAMPLESHEET2YAML.out.dataset_yaml, params.model_strategy)
      //ISOQUANT(genome_ch, SAMTOOLS_MERGE.out.samtools_mergedbam, params.model_strategy)

      // Transcript annotation modules: RNABloom
      //MERGE_FASTQ(RESTRANDER.out.restrander_fastq.collect())
      //RNA_BLOOM(MERGE_FASTQ.out.merged_fastq, shortread_ch)
      //RNABLOOM_MINIMAP2(genome_ch, RNA_BLOOM.out.rnabloom_fasta)
      //RNABLOOM_PAFTOOLS(RNABLOOM_MINIMAP2.out.rnabloom_sam)
      //RNABLOOM_AGAT_BED2GFF(RNABLOOM_PAFTOOLS.out.rnabloom_bed)
      //RNABLOOM_AGAT_GFF2GTF(RNABLOOM_AGAT_BED2GFF.out.agat_gff)

      // Merging of transcript annotations
      //AGAT_COMPLEMENT(ISOQUANT.out.isoquant_gtf, RNABLOOM_AGAT_GFF2GTF.out.agat_gtf)
      //GFFREAD(genome_ch, AGAT_COMPLEMENT.out.polished_gtf)
      //MERGE_AGAT_GFF2GTF(GFFREAD.out.gffread_gff3)
      //MERGE_ANNOTATION(annot_ch, MERGE_AGAT_GFF2GTF.out.merged_agat_gtf)
   } else if (params.oriented == true) {
      // Index creation
      index_ch = EOULSAN_INDEX(genome_ch, params.mapperName, params.mapperVersion, params.mapperFlavor, params.storages, params.tmpDir, params.binaryDir, params.indexerArguments)
      genome_ch = create_channel_from_path(params.eoulsan_genome, params.storages)
      uncompress_ch = UNCOMPRESS(genome_ch)

      // Reads filtering
      filterreads_ch = EOULSAN_READ_FILTER_SR(reads_ch, params.readFilteringConf)

      // Mapping
      filterreads_ch.combine(index_ch).set { reads_index_combined_ch }
      mapping_ch = EOULSAN_MAPPING(reads_index_combined_ch, params.mapperName, params.mapperVersion, params.mapperFlavor, params.tmpDir, params.binaryDir, params.mappersArguments)

      // Alignments filtering
      filtersam_ch = EOULSAN_SAM_FILTER(mapping_ch, params.samFilteringConf, params.tmpDir)

      // Expression computation
      filtersam_ch.combine(annot_ch).combine(genome_ch).set { filtersam_annot_combined_ch }
      expression_ch = EOULSAN_EXPRESSION(filtersam_annot_combined_ch, params.expressionConf, "True", params.storages)

      // Launch transcript annotation modules: Isoquant + RNABloom
      SAMTOOLS(EOULSAN_SAM_FILTER.out.filtered_sam)
      SAMTOOLS_MERGE(SAMTOOLS.out.samtools_bam.collect())
      ISOQUANT(uncompress_ch, SAMTOOLS_MERGE.out.samtools_mergedbam, params.model_strategy)
            
      MERGE_FASTQ(EOULSAN_READ_FILTER_SR.out.eoulsan_fasta.collect())

      RNA_BLOOM(EOULSAN_READ_FILTER_SR.out.eoulsan_fasta, shortread_ch)
      RNABLOOM_MINIMAP2(uncompress_ch, RNA_BLOOM.out.rnabloom_fasta)
      RNABLOOM_PAFTOOLS(RNABLOOM_MINIMAP2.out.rnabloom_sam)
      RNABLOOM_AGAT_BED2GFF(RNABLOOM_PAFTOOLS.out.rnabloom_bed)
      RNABLOOM_AGAT_GFF2GTF(RNABLOOM_AGAT_BED2GFF.out.agat_gff)

      // Merging of transcript annotations
      AGAT_COMPLEMENT(ISOQUANT.out.isoquant_gtf, RNABLOOM_AGAT_GFF2GTF.out.agat_gtf)
      GFFREAD(genome_ch, AGAT_COMPLEMENT.out.polished_gtf)
      MERGE_AGAT_GFF2GTF(GFFREAD.out.gffread_gff3)
      MERGE_ANNOTATION(annot_ch, MERGE_AGAT_GFF2GTF.out.merged_agat_gtf)
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