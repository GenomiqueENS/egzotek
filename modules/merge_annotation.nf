/*
========================================================================================
    MERGE_ANNOTATION module
========================================================================================
*/

// Parameter definitions
params.OUTPUT = "result/consensus"

/*
* Merge  Isoquant and RNABloom trancript models
*/

process MERGE_ANNOTATION {

   // where to store the results and in which way
    publishDir( params.OUTPUT, mode: 'copy' )

    // show in the log which input file is analysed
    debug true
    tag( "${merged_transcript}" )

    input:
    path annotation 
    tuple val(condition), path(merged_transcript)

    output:
    tuple val(condition), path( "${condition}.merged_annotation.gtf" ), emit: merged_annotation
    
    script:   
    """
    bash $projectDir/bin/merge-annotation.sh ${annotation} \
    ${merged_transcript} > ${condition}.merged_annotation.gtf
    """
}  
