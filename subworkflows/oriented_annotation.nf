/*
========================================================================================
   ORIENTED_WORKFLOW Sub-Workflow
========================================================================================
*/

include { RESTRANDER }                           from '../modules/restrander.nf'
include { UPDATE_SAMPLESHEET_AFTER_RESTRANDER }  from '../modules/restrander.nf'
include { COMMON_WORKFLOW }                      from './common_annotation.nf'

/*
 *  New SMART-Seq : Can be oriented with Eoulsan after alignment or with RESTRANDER
 */
workflow ORIENTED_WORKFLOW {
   take:
      genome_file
      annot_file
      restrander_config_file
      shortread_file
      junc_bed_file
      samplesheet_ch
      reads_ch
      
   main:

      // TODO Handle Eoulsan reorientation

      // Restrander
      RESTRANDER(reads_ch, restrander_config_file)

      // Update sample sheet
      all_ch = RESTRANDER.out.input_output_tuple.collect(flat: false)
      UPDATE_SAMPLESHEET_AFTER_RESTRANDER( all_ch, samplesheet_ch)

      COMMON_WORKFLOW(genome_file,
                      annot_file,
                      shortread_file,
                      junc_bed_file,
                      UPDATE_SAMPLESHEET_AFTER_RESTRANDER.out,
                      RESTRANDER.out.restrander_fastq)

}
