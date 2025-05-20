/*
========================================================================================
   ORIENTED_WORKFLOW Sub-Workflow
========================================================================================
*/

include { RESTRANDER }                                                                          from '../modules/restrander.nf'
include { COMMON_WORKFLOW }                                                                     from './common_annotation.nf'

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
      samplesheet_path
      reads_ch
      
   main:

      // TODO Handle Eoulsan reorientation

      // Restrander
      RESTRANDER(reads_ch, restrander_config_file)

      COMMON_WORKFLOW(genome_file,
                      annot_file,
                      shortread_file,
                      junc_bed_file,
                      samplesheet_path,
                      RESTRANDER.out.restrander_fastq)

}
