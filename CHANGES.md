# Changelog

## 0.3 (TBD)
* Add a shebang in main.nf.
* Remove shebang and dsl2 directive in modules.
* Check if samplesheet, genome, annotation and sam parameters has been defined using assets.
* Rename variable name ending with \_ch that are not Channel objects.
* Fix the default path for Restrander configuration file in nextflow.config.
* Print the Nextflow launchDir and projectDir in summary.
* Timeline, report, trace and dag files are now generated in the execution subdirectory of the launch directory.
* Fix usage of params.outdir by publishDir directives.
* Now use link mode for publishDir directive in modules.
* Replace samplesheet2yaml.py external script by pure Groovy code.
* Now use the samplesheet to create the Channel for FASTQ files.
* NONORIENTED\_WORKFLOW and ORIENTED\_WORKFLOW now depends on COMMON\_WORKFLOW for the common parts. 
* The MERGE\_FASTQ process does not now use an external python script.
* Use the task.cpus variable for the number of threads to use for minimap2, rnabloom or isoquant processes.
* Fix in restrander.nf, input FASTQ file was emit instead of the real output FASTQ file.
* Remove unnessessary println or view().
* In agat.nf, isoquant.nf and rnabloom.nf write stdout and stderr in files.
* Remove the unnecessary "reads" parameter of the workflow.
* Update tags of the MERGE\_FASTQ, RNA\_BLOOM and SAMPLESHEET2YAML process.
* Add the workflow.commandLine, workflow.launchDir and nextflow.version in summary at the workflow startup.
* In modules/merge\_fastq.nf, add shebang for the script generated in modules/merge\_fastq.nf.
* In modules/rnabloom.nf, now use Java -XX:MaxRAMPercentage=65.0 to define memory required by RNA-Bloom.
* Add profiles for medium and high memory.
* Now use restrander 1.1.1.

## 0.2 (2024-11-18)
* Fixed bugs in pipeline.
* Added gffread parameter.
* Fixed Isoquant missing bams issue.
* Adjusted CPU requirement.
* Added parameters for RNABloom minimap2.
* Added uncompress genome option.

## 0.1 (2024-10-30)
* Initial version.
