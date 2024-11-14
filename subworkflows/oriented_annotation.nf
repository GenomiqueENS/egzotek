/*
========================================================================================
   ORIENTED_WORKFLOW Sub-Workflow
========================================================================================
*/

include { GFFREAD }                                                                             from '../modules/gffread.nf' 
include { ISOQUANT; ISOQUANT_CONDITION }                                                        from '../modules/isoquant.nf'
include { MINIMAP2 }                                                                            from '../modules/minimap2.nf'
include { MERGE_ANNOTATION }                                                                    from '../modules/merge_annotation.nf'
include { MERGE_FASTQ_EOULSAN }                                                                 from '../modules/merge_fastq.nf'
include { RNA_BLOOM }                                                                           from '../modules/rnabloom.nf'
include { RNABLOOM_MINIMAP2 }                                                                   from '../modules/rnabloom_minimap2.nf'
include { RNABLOOM_PAFTOOLS }                                                                   from '../modules/rnabloom_paftools.nf'
include { RNABLOOM_AGAT_BED2GFF; RNABLOOM_AGAT_GFF2GTF; AGAT_COMPLEMENT; MERGE_AGAT_GFF2GTF }   from '../modules/agat.nf'
include { SAMPLESHEET2YAML }                                                                    from '../modules/samplesheet2yaml.nf'
include { SAMTOOLS }                                                                            from '../modules/samtools.nf'
include { UNCOMPRESS_GENOME }                                                                   from '../modules/uncompress_files.nf'

workflow ORIENTED_WORKFLOW {
   take:
      annot
      config
      shortread
      junc_bed
      samplesheet
      sam
      reads
      
   main:
      // Prepare genome for different steps
      ch_isoquant_genome = Channel.empty()      
      if (params.genome.endsWith('.gz')|| params.genome.endsWith(".bz2")){
            genome_ch = file( params.genome )
            UNCOMPRESS_GENOME(genome_ch)
            ch_isoquant_genome = UNCOMPRESS_GENOME.out.genome_isoquant
            ch_minimap2_genome = UNCOMPRESS_GENOME.out.genome_minimap2
            ch_gffread_genome  = UNCOMPRESS_GENOME.out.genome_gffread
      } else {
            ch_isoquant_genome = file( params.genome )
            ch_minimap2_genome = file( params.genome )
            ch_gffread_genome  = file( params.genome )
      }

      // Transcript annotation modules: IsoQuant
      SAMTOOLS(sam)
      SAMPLESHEET2YAML(samplesheet)
      ISOQUANT(SAMTOOLS.out.process_control.collect(), SAMTOOLS.out.samtools_bam.collect(), ch_isoquant_genome, SAMPLESHEET2YAML.out.dataset_yaml, params.model_strategy)
      ISOQUANT_CONDITION(ISOQUANT.out.isoquant_gtf.flatten())

      // Transcript annotation modules: RNABloom
      MERGE_FASTQ_EOULSAN(samplesheet, reads.collect())
      RNA_BLOOM(MERGE_FASTQ_EOULSAN.out.merged_fastq.flatten(), shortread)
      RNABLOOM_MINIMAP2(ch_minimap2_genome, RNA_BLOOM.out.rnabloom_fasta, params.intron_length, junc_bed)
      RNABLOOM_PAFTOOLS(RNABLOOM_MINIMAP2.out.rnabloom_sam)
      RNABLOOM_AGAT_BED2GFF(RNABLOOM_PAFTOOLS.out.rnabloom_bed)
      RNABLOOM_AGAT_GFF2GTF(RNABLOOM_AGAT_BED2GFF.out.agat_gff)

      // Merging of transcript annotations
      AGAT_COMPLEMENT(ISOQUANT_CONDITION.out.isoquant_condition_gtf.join(RNABLOOM_AGAT_GFF2GTF.out.agat_gtf))
      GFFREAD(ch_gffread_genome, AGAT_COMPLEMENT.out.polished_gtf, params.gffread_parameters)
      MERGE_AGAT_GFF2GTF(GFFREAD.out.gffread_gff3)
      MERGE_ANNOTATION(annot, MERGE_AGAT_GFF2GTF.out.merged_agat_gtf)
}
