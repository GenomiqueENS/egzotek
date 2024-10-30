/*
========================================================================================
   NONORIENTED_WORKFLOW Sub-Workflow
========================================================================================
*/

include { GFFREAD }                                                                             from '../modules/gffread.nf' 
include { ISOQUANT; ISOQUANT_CONDITION }                                                        from '../modules/isoquant.nf'
include { MINIMAP2 }                                                                            from '../modules/minimap2.nf'
include { MERGE_ANNOTATION }                                                                    from '../modules/merge_annotation.nf'
include { MERGE_FASTQ_RESTRANDER }                                                              from '../modules/merge_fastq.nf'
include { RESTRANDER }                                                                          from '../modules/restrander.nf'
include { RNA_BLOOM }                                                                           from '../modules/rnabloom.nf'
include { RNABLOOM_MINIMAP2 }                                                                   from '../modules/rnabloom_minimap2.nf'
include { RNABLOOM_PAFTOOLS }                                                                   from '../modules/rnabloom_paftools.nf'
include { RNABLOOM_AGAT_BED2GFF; RNABLOOM_AGAT_GFF2GTF; AGAT_COMPLEMENT; MERGE_AGAT_GFF2GTF }   from '../modules/agat.nf'
include { SAMPLESHEET2YAML }                                                                    from '../modules/samplesheet2yaml.nf'
include { SAMTOOLS }                                                                            from '../modules/samtools.nf'

workflow NONORIENTED_WORKFLOW {
   take: 
      genome
      annot
      config
      shortread
      junc_bed
      samplesheet
      reads

   main:
      RESTRANDER(reads, config)
      // Transcript annotation modules: Isoquant
      MINIMAP2(genome, RESTRANDER.out.restrander_fastq, params.intron_length, junc_bed)
      SAMTOOLS(MINIMAP2.out.isoquant_sam)
      SAMPLESHEET2YAML(samplesheet)
      ISOQUANT(SAMTOOLS.out.process_control.collect(), genome, SAMPLESHEET2YAML.out.dataset_yaml, params.model_strategy)
      ISOQUANT_CONDITION(ISOQUANT.out.isoquant_gtf.flatten())

      // Transcript annotation modules: RNABloom
      MERGE_FASTQ_RESTRANDER(samplesheet, reads, RESTRANDER.out.process_control.collect())
      RNA_BLOOM(MERGE_FASTQ_RESTRANDER.out.merged_fastq.flatten(), shortread)
      RNABLOOM_MINIMAP2(genome, RNA_BLOOM.out.rnabloom_fasta)
      RNABLOOM_PAFTOOLS(RNABLOOM_MINIMAP2.out.rnabloom_sam)
      RNABLOOM_AGAT_BED2GFF(RNABLOOM_PAFTOOLS.out.rnabloom_bed)
      RNABLOOM_AGAT_GFF2GTF(RNABLOOM_AGAT_BED2GFF.out.agat_gff)

      // Merging of transcript annotations
      AGAT_COMPLEMENT(ISOQUANT_CONDITION.out.isoquant_condition_gtf.join(RNABLOOM_AGAT_GFF2GTF.out.agat_gtf))
      GFFREAD(genome, AGAT_COMPLEMENT.out.polished_gtf)
      MERGE_AGAT_GFF2GTF(GFFREAD.out.gffread_gff3)
      MERGE_ANNOTATION(annot, MERGE_AGAT_GFF2GTF.out.merged_agat_gtf)
}





