params.OUTPUT = "result/eoulsan"

import fr.ens.biologie.genomique.kenetre.io.CompressionType
import fr.ens.biologie.genomique.kenetre.util.LocalReporter
import fr.ens.biologie.genomique.kenetre.bio.io.TSVCountsWriter
import fr.ens.biologie.genomique.kenetre.bio.expressioncounter.ExpressionCounterService

include { read_conf; get_path; get_genome_desc; input_stream; output_stream } from './common.nf'

process EOULSAN_EXPRESSION {
 
    publishDir( "${params.outdir}/expression", mode: 'copy' )
    
    input:
    tuple val(inSam), val(annot), val(genome)
    // val inSam
    // val annot
    // val genome
    val conf
    val isGtf
    val storages
 
    output:
    path "expression_${inSam.baseName}.tsv"
 
    exec:

    // Convert inSam to File object
    inSamFile = file(inSam)

    // Get genome file
    genomeFile = get_path(genome.toString(), storages)

    // Get annot file
    annotFile = get_path(annot.toString(), storages)

    // Get out file object
    expressionFile = task.workDir.resolve("expression_${inSam.baseName}.tsv")

    // Get genome description
    gd = get_genome_desc(genomeFile.toString(), storages)

    // Create the reporter
    reporter = new LocalReporter();

    // Create the counter object
    counter = ExpressionCounterService.getInstance().newService("htseq-count")

    // Set counter parameters
    conf.each{ k, v -> counter.setParameter(k, v) }

    // Initialize the counter
    counter.init(gd, input_stream(annotFile), Boolean.parseBoolean(isGtf));

    // Launch counting
    result = counter.count(input_stream(inSamFile), reporter,
            "expression");

    // Add features with zero count
    counter.addZeroCountFeatures(result);

    // Save result
    writer = new TSVCountsWriter(expressionFile.toFile())
    writer.write(result)
    writer.close()
}
