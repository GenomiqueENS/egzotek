/*
========================================================================================
    MERGE_ANNOTATION module
========================================================================================
*/

// Parameter definitions
params.OUTPUT = "result/merge_annotation"

/*
* Merge  Isoquant trancript model
*/

process MERGE_ANNOTATION {

   // where to store the results and in which way
    publishDir( params.OUTPUT, mode: 'copy' )

    // show in the log which input file is analysed
    debug true

    input:
    path annotation 
    path merged_transcript

    output:
    path( "merged_annotation.gtf" ), emit: merged_annotation
    
    script:   
    """
    bash $projectDir/bin/merge-annotation.sh ${annotation} \
    ${merged_transcript} > merged_annotation.gtf
    """
}  
