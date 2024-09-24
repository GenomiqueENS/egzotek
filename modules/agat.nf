/*
========================================================================================
   AGAT module
========================================================================================
*/

// Parameter definitions
params.OUTPUT = "result/rnabloom"

/*
* AGAT Conversion bed > gff
*/

process RNABLOOM_AGAT_BED2GFF {
   // where to store the results and in which way
   debug true
   publishDir( params.OUTPUT, mode: 'copy' )

   // show in the log which input file is analysed
   tag( "${bloombed}" )
   
   input:
   path bloombed 
   
   output:
   path("rnabloom.transcripts.gff"), emit: agat_gff
   
   script:
   """
   /usr/local/bin/agat_convert_bed2gff.pl \
   --bed ${bloombed} \
   -o rnabloom.transcripts.gff
   """
}

/*
* AGAT Conversion gff > gtf
*/

process RNABLOOM_AGAT_GFF2GTF {
   // where to store the results and in which way
   debug true
   publishDir( params.OUTPUT, mode: 'copy' )

   // show in the log which input file is analysed
   tag( "${agat_gtf}" )
   
   input:
   path agat_gtf 
   
   output:
   path("rnabloom.transcripts.gtf"), emit: agat_gtf
   
   script:
   """
   /usr/local/bin/agat_convert_sp_gff2gtf.pl \
   --gff ${agat_gtf} \
   -o rnabloom.transcripts.gtf
   """
}

/*
* AGAT Conversion gff > gtf
*/

process MERGE_AGAT_GFF2GTF {
   // where to store the results and in which way
   debug true
   publishDir( params.OUTPUT, mode: 'copy' )

   // show in the log which input file is analysed
   tag( "${merged_gff}" )
   
   input:
   path merged_gff 
   
   output:
   path("merged_transcripts.gtf"), emit: merged_agat_gtf
   
   script:
   """
   /usr/local/bin/agat_convert_sp_gff2gtf.pl \
   --gff ${merged_gff} \
   -o merged_transcripts.gtf
   """
}


/*
* AGAT Regroupement des modèles
*/

process AGAT_COMPLEMENT {
   // where to store the results and in which way
   debug true
   publishDir( params.OUTPUT, mode: 'copy' )

   // show in the log which input file is analysed
   tag( "${isoquant_gtf}, ${agat_gtf}" )
   
   input:
   path isoquant_gtf
   path agat_gtf 
   
   output:
   path("polished_transcriptome.gtf"), emit: polished_gtf
   
   script:
   """
   /usr/local/bin/agat_sp_complement_annotations.pl \
   --ref ${isoquant_gtf} \
   --add ${agat_gtf} \
   --out polished_transcriptome.gtf
   """
}