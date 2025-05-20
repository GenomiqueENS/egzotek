/*
========================================================================================
   ORIENTED_WORKFLOW Sub-Workflow
========================================================================================
*/

include { GFFREAD }                                                                             from '../modules/gffread.nf'
include { ISOQUANT; ISOQUANT_CONDITION }                                                        from '../modules/isoquant.nf'
include { MINIMAP2 }                                                                            from '../modules/minimap2.nf'
include { MERGE_ANNOTATION }                                                                    from '../modules/merge_annotation.nf'
include { MERGE_FASTQ }                                                                         from '../modules/merge_fastq.nf'
include { RNA_BLOOM }                                                                           from '../modules/rnabloom.nf'
include { RNABLOOM_MINIMAP2 }                                                                   from '../modules/rnabloom_minimap2.nf'
include { RNABLOOM_PAFTOOLS }                                                                   from '../modules/rnabloom_paftools.nf'
include { RNABLOOM_AGAT_BED2GFF; RNABLOOM_AGAT_GFF2GTF; AGAT_COMPLEMENT; MERGE_AGAT_GFF2GTF }   from '../modules/agat.nf'
include { SAMPLESHEET2YAML }                                                                    from '../modules/samplesheet2yaml.nf'
include { SAMTOOLS }                                                                            from '../modules/samtools.nf'
include { UNCOMPRESS_GENOME }                                                                   from '../modules/uncompress_files.nf'
include { createConditionChannelFromSampleSheet }                                               from '../modules/samplesheet.nf'

workflow COMMON_WORKFLOW {

   take:
      genome_file
      annot_file
      shortread_file
      junc_bed_file
      samplesheet_path
      reads_ch

    main:

        samplesheet_ch = Channel.fromPath( samplesheet_path, checkIfExists:true )

        // Prepare genome for different steps
        if (genome_file.name.endsWith('.gz' )|| genome_file.name.endsWith(".bz2")){
            UNCOMPRESS_GENOME(genome_file)
            ch_isoquant_genome = UNCOMPRESS_GENOME.out.genome_isoquant
            ch_minimap2_genome = UNCOMPRESS_GENOME.out.genome_minimap2
            ch_gffread_genome  = UNCOMPRESS_GENOME.out.genome_gffread
        } else {
            ch_isoquant_genome = genome_file
            ch_minimap2_genome = genome_file
            ch_gffread_genome  = genome_file
        }

        MINIMAP2(ch_minimap2_genome, reads_ch, params.intron_length, junc_bed_file)
        SAMTOOLS(MINIMAP2.out.isoquant_sam)
        SAMPLESHEET2YAML(samplesheet_ch)
        ISOQUANT(SAMTOOLS.out.process_control.collect(),
                 SAMTOOLS.out.samtools_bam.collect(),
                 ch_isoquant_genome,
                 SAMPLESHEET2YAML.out.dataset_yaml,
                 params.model_strategy)
        ISOQUANT_CONDITION(ISOQUANT.out.isoquant_gtf.flatten())

        // Transcript annotation modules: RNABloom
        fastq_to_merge_ch = createConditionChannelFromSampleSheet(samplesheet_path)
        fastq_to_merge_ch.collect().view()
        MERGE_FASTQ(fastq_to_merge_ch)

        RNA_BLOOM(MERGE_FASTQ.out.merged_fastq.flatten(), shortread_file)
        RNABLOOM_MINIMAP2(ch_minimap2_genome, RNA_BLOOM.out.rnabloom_fasta, params.intron_length, junc_bed_file)
        RNABLOOM_PAFTOOLS(RNABLOOM_MINIMAP2.out.rnabloom_sam)
        RNABLOOM_AGAT_BED2GFF(RNABLOOM_PAFTOOLS.out.rnabloom_bed)
        RNABLOOM_AGAT_GFF2GTF(RNABLOOM_AGAT_BED2GFF.out.agat_gff)

        // Merging of transcript annotations
        AGAT_COMPLEMENT(ISOQUANT_CONDITION.out.isoquant_condition_gtf.join(RNABLOOM_AGAT_GFF2GTF.out.agat_gtf))
        GFFREAD(ch_gffread_genome, AGAT_COMPLEMENT.out.polished_gtf, params.gffread_parameters)
        MERGE_AGAT_GFF2GTF(GFFREAD.out.gffread_gff3)
        MERGE_ANNOTATION(annot_file, MERGE_AGAT_GFF2GTF.out.merged_agat_gtf)
}