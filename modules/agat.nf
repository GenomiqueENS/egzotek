/*
========================================================================================
   AGAT module
========================================================================================
*/

/*
* AGAT Conversion bed > gff
*/

process RNABLOOM_AGAT_BED2GFF {
   debug true

   // where to store the results and in which way
   publishDir( "${params.outdir}/rnabloom", mode: 'link' )

   // show in the log which input file is analysed
   tag( "${bloombed}" )
   
   input:
   tuple val(condition), path(bloombed)
   
   output:
   tuple val(condition), path("${bloombed.SimpleName}.gff"), emit: agat_gff
   
   script:
   """
   /usr/local/bin/agat_convert_bed2gff.pl \
   --bed ${bloombed} \
   --source "RNABloom" \
   -o ${bloombed.SimpleName}.gff > agat.out 2> agat.err
   """
}

/*
* AGAT Conversion gff > gtf
*/

process RNABLOOM_AGAT_GFF2GTF {
   debug true

   // where to store the results and in which way
   publishDir( "${params.outdir}/rnabloom", mode: 'link' )

   // show in the log which input file is analysed
   tag( "${agat_gtf}" )
   
   input:
   tuple val(condition), path(agat_gtf)
   
   output:
   tuple val(condition), path("${agat_gtf.SimpleName}_rnabloom.gtf"), emit: agat_gtf
   
   script:
   """
   /usr/local/bin/agat_convert_sp_gff2gtf.pl \
   --gff ${agat_gtf} \
   -o ${agat_gtf.SimpleName}_rnabloom.gtf > agat.out 2> agat.err
   """
}

/*
* AGAT Conversion gff > gtf
*/

process MERGE_AGAT_GFF2GTF {
   debug true

   // where to store the results and in which way
   publishDir( "${params.outdir}/consensus", mode: 'link' )

   // show in the log which input file is analysed
   tag( "${merged_gff}" )
   
   input:
   tuple val(condition), path(merged_gff)
   
   output:
   tuple val(condition), path("${condition}.merged_transcripts.gtf"), emit: merged_agat_gtf
   
   script:
   """
   /usr/local/bin/agat_convert_sp_gff2gtf.pl \
   --gff ${merged_gff} \
   -o ${condition}.merged_transcripts.gtf > agat.out 2> agat.err
   """
}


/*
* AGAT Regroupement des modèles
*/

process AGAT_COMPLEMENT {
   debug true

   // where to store the results and in which way
   publishDir( "${params.outdir}/consensus", mode: 'link' )

   // show in the log which input file is analysed
   tag( "${isoquant_gtf}, ${rnabloom_gtf}" )
   
   input:
   tuple val(condition), path(isoquant_gtf), path(rnabloom_gtf)
   
   output:
   tuple val(condition), path("${condition}.polished_transcriptome.gtf"), emit: polished_gtf
   
   script:
   """
   /usr/local/bin/agat_sp_complement_annotations.pl \
   --ref ${isoquant_gtf} \
   --add ${rnabloom_gtf} \
   --out ${condition}.polished_transcriptome.gtf > agat.out 2> agat.err
   """
}