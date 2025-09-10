include { readCSV as readSamplesheetCSV }        from '../modules/samplesheet.nf'

/*
========================================================================================
   RESTRANDER module
========================================================================================
*/

process RESTRANDER {
   debug true

   // where to store the results and in which way
   publishDir( "${params.outdir}/restrander", mode: 'link' )

   // show in the log which input file is analysed
   debug true
   tag( "${fastq}" )

   input:
   path fastq 
   path config

   output:
   path( "${fastq}" ), emit: restrander_input
   path( "${fastq.SimpleName}-restrander.fastq.gz" ), emit: restrander_fastq
   path( "${fastq.SimpleName}.json" ), emit: restrander_stats
   tuple path(fastq), path( "${fastq.SimpleName}-restrander.fastq.gz" ), emit: input_output_tuple

   script:
   """
   restrander ${fastq} \
   ${fastq.SimpleName}-restrander.fastq.gz  \
   ${config} > ${fastq.SimpleName}.json
   """

   stub:
   """
   touch ${fastq.SimpleName}-restrander.fastq
   gzip ${fastq.SimpleName}-restrander.fastq
   touch ${fastq.SimpleName}.json
   """
}

process UPDATE_SAMPLESHEET_AFTER_RESTRANDER {
    debug true

    input:
    val inout_tuple
    val samplesheet

    output:
    path("samplesheet.csv")

    exec:
    def samplesheetDir = samplesheet.getParent()
    def entries = readSamplesheetCSV(samplesheet)
    def pathMap = {}

    inout_tuple.each{
        pathMap.put(it[0].toRealPath().toString(), it[1].toString())
    }

    def content = "fastq,sample,condition\n"

    entries.each {
        def fastq = it['fastq']

        def p = null
        if (!fastq.startsWith('/')) {
            p = java.nio.file.Paths.get(samplesheetDir.toString(), fastq)
        } else {
            p =  java.nio.file.Paths.get(fastq)
        }

        if (pathMap.containsKey(p.toRealPath().toString())) {
            fastq = pathMap[p.toRealPath().toString()]
        }
        it['fastq'] = fastq
        content += it["fastq"] + "," + it["sample"] + "," + it["condition"] + "\n"
    }

    def outputFile = task.workDir.resolve("samplesheet.csv")
    outputFile.write(content)
}
