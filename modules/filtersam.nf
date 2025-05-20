params.OUTPUT = "result/eoulsan"

import fr.ens.biologie.genomique.kenetre.util.LocalReporter
import fr.ens.biologie.genomique.kenetre.bio.alignmentfilter.MultiReadAlignmentFilterBuilder
import fr.ens.biologie.genomique.kenetre.bio.alignmentfilter.ReadAlignmentFilterBuffer
import fr.ens.biologie.genomique.kenetre.bio.SAMComparator
import htsjdk.samtools.SAMFormatException
import htsjdk.samtools.SAMRecord
import htsjdk.samtools.SamInputResource
import htsjdk.samtools.SamReaderFactory
import htsjdk.samtools.SAMFileWriterFactory

/*
 * Eoulsan SAM filter
 */
process EOULSAN_SAM_FILTER {
 
    publishDir( "${params.outdir}/filtersam", mode: 'link' )
    
    input:
    val inSam
    val conf
    val tmpDir
 
    output:
    path "${inSam.baseName}.sam", emit: filtered_sam
 
    exec:

    // Convert inFastq to File object
    inSamFile = file(inSam)

    // Get out file object
    outSamFile = task.workDir.resolve("${inSam.baseName}.sam")

    // Define the reporter
    reporter = new LocalReporter()
    counterGroup = "sam_filtering"

    // Define the filters
    builder = new MultiReadAlignmentFilterBuilder()
    builder.useNewServiceInstance(true)
    builder.addParameters(conf)
    filter = builder.getAlignmentFilter(reporter, counterGroup)

    // Creation of a buffer object to store alignments with the same read name
    rafb = new ReadAlignmentFilterBuffer(filter);

    records = []
    counterInput = 0
    counterOutput = 0
    counterInvalid = 0
    pairedEnd = false

    // Get reader
    reader = SamReaderFactory.makeDefault().open(SamInputResource.of(inSamFile))

    // Get writer
    outputSam =
        new SAMFileWriterFactory().setTempDirectory(tmpDir.toFile())
            .makeSAMWriter(reader.getFileHeader(), false, outSamFile)

    it = reader.iterator();
    while (it.hasNext()) {

        samRecord = null

        // Check if SAM entry is correct
        try {
            samRecord = it.next()
        } catch (SAMFormatException e) {
            counterInvalid++
            continue
        }

        // single-end or paired-end mode ?
        if (counterInput == 0) {
            if (samRecord.getReadPairedFlag()) {
                pairedEnd = true
            }
        }

        counterInput++

        // storage and filtering of all the alignments of a read in the list
        // "records"
        if (!rafb.addAlignment(samRecord)) {

            records.clear()
            records.addAll(rafb.getFilteredAlignments())

            // sort alignments of the current read
            records.sort(new SAMComparator())

            // writing records
            for (r in records) {
                outputSam.addAlignment(r)
                counterOutput++
            }

            rafb.addAlignment(samRecord)
        }
    }

    // treatment of the last record
    records.clear()
    records.addAll(rafb.getFilteredAlignments())

    // sort alignments of the last read
    records.sort(new SAMComparator())

    // writing records
    for (r in records) {
      outputSam.addAlignment(r)
      counterOutput++
    }

    // paired-end mode
    if (pairedEnd) {
      nbInput = counterInput / 2
      nbOutput = counterOutput / 2
      reporter.incrCounter(counterGroup, "input alignments", nbInput)
      reporter.incrCounter(counterGroup, "output filtered alignments", nbOutput)
      reporter.incrCounter(counterGroup, "alignments in invalid sam format", counterInvalid / 2)
      reporter.incrCounter(counterGroup, "alignments rejected by filters", nbInput - nbOutput)
    }

    // single-end mode
    else {
      reporter.incrCounter(counterGroup, "input alignments", counterInput)
      reporter.incrCounter(counterGroup, "output filtered alignments", counterOutput)
      reporter.incrCounter(counterGroup, "alignments in invalid sam format", counterInvalid)
      reporter.incrCounter(counterGroup, "alignments rejected by filters", counterInput - counterOutput)
    }

    // Close files
    reader.close()
    outputSam.close()
}
