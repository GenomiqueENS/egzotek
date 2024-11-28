/*
========================================================================================
   SAMPLESHEET2YAML module
========================================================================================
*/

/*
* Convert samplesheet into YAML for IsoQuant
*/

process SAMPLESHEET2YAML {

   // where to store the results and in which way
   publishDir( "${params.outdir}/isoquant", mode: 'copy' )

   // show in the log which input file is analysed
   tag( "${samplesheet}" )

   input:
   path samplesheet

   output:
   path( "dataset.yaml" ), emit: dataset_yaml
   
   script:
   """
   python3 $projectDir/bin/samplesheet2yaml.py --input ${samplesheet} --output dataset.yaml
   """
}  