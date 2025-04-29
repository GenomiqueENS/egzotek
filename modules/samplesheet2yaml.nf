/*
========================================================================================
   SAMPLESHEET2YAML module
========================================================================================
*/

/*
* Convert samplesheet into YAML for IsoQuant
*/

include { csv2yaml } from './samplesheet.nf'

process SAMPLESHEET2YAML {

   debug true

   input:
   val samplesheet

   output:
   path( "dataset.yaml" ), emit: dataset_yaml
   
   exec:
   csv2yaml(samplesheet.toRealPath(), task.workDir.resolve('dataset.yaml'))
}
