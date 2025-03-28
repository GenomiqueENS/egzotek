/*
========================================================================================
    GFFREAD module
========================================================================================
*/

/*
* AGAT Conversion bed > gff
*/

process GFFREAD {
   // where to store the results and in which way
    debug true
    publishDir( "${params.outdir}/consensus", mode: 'link' )

    // show in the log which input file is analysed
    tag( "${polished_gtf}" )
    
    input:
    path genome
    tuple val(condition), path(polished_gtf)
    val gffread_parameters
    
    output:
    tuple val(condition), path("${condition}.transcripts_polished_clustersMKZ.gff3"), emit: gffread_gff3
    
    script:
    """
    gffread  -g ${genome} \
    -o ${condition}.transcripts_polished_clustersMKZ.gff3 \
    ${gffread_parameters} ${polished_gtf} 
    """
}
