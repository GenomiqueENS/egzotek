/*
========================================================================================
   SAMPLESHEET2YAML module
========================================================================================
*/

// Parameter definitions
params.OUTPUT = "result/isoquant"

/*
* Convert samplesheet into YAML for IsoQuant
*/

process SAMPLESHEET2YAML {

   // where to store the results and in which way
   publishDir( params.OUTPUT, mode: 'copy' )

   // show in the log which input file is analysed
   debug true
   tag( "${samplesheet}" )

   input:
   path samplesheet

   output:
   path( "dataset.yaml" ), emit: dataset_yaml
   
   script:
   base_path = params.reads.substring(0, params.reads.lastIndexOf('/'))   
   """
   python3 $projectDir/bin/samplesheet2yaml.py --input ${samplesheet} --output dataset.yaml --path $projectDir/result/isoquant
   """
}  