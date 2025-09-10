/*
========================================================================================
   MERGE_FASTQ module
========================================================================================

/*
* Merge Fast
*/

process MERGE_FASTQ {
   debug true

   // where to store the results and in which way
   publishDir( "${params.outdir}/rnabloom", mode: 'link' )

   // show in the log which input file is analysed
   tag( "${condition_name}.fastq" )

   input:
   tuple val(condition_name), val(file_list)

   output:
   path( "*.fastq" ), emit: merged_fastq

   script:
   files = file_list.join(' ')

   if (files.size() == 1 && (files.endsWith('.fq') || files.endsWith('.fastq') )) {
      """
      #!/bin/bash

      ln -s $files ${condition_name}.fastq
      """
   } else {
   """
   #!/bin/bash

   # Avoid exiting file
   > "${condition_name}.fastq"

   # For each FASTQ of the condition
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
