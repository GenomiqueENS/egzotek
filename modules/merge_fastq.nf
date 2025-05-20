/*
========================================================================================
   MERGE_FASTQ module
========================================================================================

/*
* Merge Fast
*/

include { createConditionChannelFromSampleSheet } from './samplesheet.nf'

process MERGE_FASTQ {
   // where to store the results and in which way
   debug true
   publishDir( "${params.outdir}/rnabloom", mode: 'link' )

   tag( "${reads}" )

   input:
   val entry

   output:
   path( "*.fastq" ), emit: merged_fastq

   script:
   condition_name = entry[0]
   file_list = entry.subList(1, entry.size())
   files = file_list.join(' ')

   if (files.size() == 1 && (files.endsWith('.fq') || files.endsWith('.fastq') )) {
      """
      ln -s $files ${condition_name}.fastq
      """
   } else {
   """
   # Avoid exiting file
   > "${condition_name}.fastq"

   # Parcourir tous les fichiers du répertoire
   for file in ${files} ; do
      case "\$file" in
         *.gz)
            # gzip file
            zcat "\$file" >> "${condition_name}.fastq"
            ;;
         *.bz2)
            # bzip2 file
            bzcat "\$file" >> "${condition_name}.fastq"
            ;;
         *.xz)
            # xz file
            xzcat "\$file" >> "${condition_name}.fastq"
            ;;
         *)
            # uncompressed file
            cat "\$file" >> "${condition_name}.fastq"
            ;;
      esac
   done
   """
   }
}
