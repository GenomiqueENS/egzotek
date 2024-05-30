/*
========================================================================================
    GFFREAD module
========================================================================================
*/

// Parameter definitions
params.OUTPUT = "result/gffread"

/*
* AGAT Conversion bed > gff
*/

process GFFREAD {
   // where to store the results and in which way
    debug true
    publishDir( params.OUTPUT, mode: 'copy' )

    // show in the log which input file is analysed
    tag( "${polished_gtf}" )
    
    input:
    path genome
    path polished_gtf 
    
    output:
    path("transcripts_polished_clustersMKZ.gff3"), emit: gffread_gff3
    
    script:
    """
    gffread  -g ${genome} \
    -o transcripts_polished_clustersMKZ.gff3 \
    -M -K -Z ${polished_gtf} \
    """
}
