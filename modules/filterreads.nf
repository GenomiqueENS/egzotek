#!/usr/bin/env nextflow
nextflow.enable.dsl=2
params.OUTPUT = "result/eoulsan"
import java.io.File
import fr.ens.biologie.genomique.kenetre.util.StringUtils
import fr.ens.biologie.genomique.kenetre.io.CompressionType
import fr.ens.biologie.genomique.kenetre.util.LocalReporter
import fr.ens.biologie.genomique.kenetre.bio.readfilter.MultiReadFilterBuilder
import fr.ens.biologie.genomique.kenetre.bio.io.FastqReader
import fr.ens.biologie.genomique.kenetre.bio.io.FastqWriter

/*
 * Eoulsan read filter, single end mode
 */
process EOULSAN_READ_FILTER_SR {
 
    debug true
    publishDir( params.OUTPUT, mode: 'copy' )
    
    input:
    val inFastq
    val conf
 
    output:
    //stdout
    //path outputFile
    path "filtered_${inFastq.baseName}", emit: eoulsan_fasta
 
    exec:
    
    // Convert inFastq to File object
    inFastqFile = file(inFastq)

    // Get out file object
    outFastqFile = task.workDir.resolve("filtered_${inFastq.baseName}")

    // Get input compression
    inCompression = CompressionType.getCompressionTypeByFile(inFastqFile)

    // Get output compression
    outCompression = CompressionType.getCompressionTypeByFile(outFastqFile)

    // Define the reporter
    reporter = new LocalReporter()
    counterGroup = "reads_filtering"

    // Define the filters
    builder = new MultiReadFilterBuilder()
    builder.useNewServiceInstance(true)
    builder.addParameters(conf)
    filter = builder.getReadFilter(reporter, counterGroup)

    // Open input file, uncompress the stream if necessary
    reader = new FastqReader(inCompression.open(inFastqFile))
    writer = new FastqWriter(outCompression.create(outFastqFile))
    for (read in reader) {

        // Increment input read counter
        reporter.incrCounter(counterGroup, "input raw reads", 1)

        // Test if read pass the filter
        if (filter.accept(read)) {
            //println(read.toFastQ())
            writer.write(read)

            // Incremeent ouput read counter
            reporter.incrCounter(counterGroup, "output accepted reads", 1)
        }
    }

    // Throw an exception if an error has occured while reading the file
    reader.throwException()

    // Close the reader
    reader.close()

    // Close the writer
    writer.close()

    //println(reporter)
}
