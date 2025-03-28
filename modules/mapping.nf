params.OUTPUT= "result/eoulsan"

import static fr.ens.biologie.genomique.kenetre.util.StringUtils.filenameWithoutExtension

import java.nio.charset.StandardCharsets
import java.nio.file.Files

import fr.ens.biologie.genomique.kenetre.bio.FastqFormat
import fr.ens.biologie.genomique.kenetre.bio.readmapper.MapperBuilder
import fr.ens.biologie.genomique.kenetre.bio.readmapper.MapperInstanceBuilder
import fr.ens.biologie.genomique.kenetre.bio.readmapper.MapperUtils
import fr.ens.biologie.genomique.kenetre.io.CompressionType
import fr.ens.biologie.genomique.kenetre.io.FileUtils
import fr.ens.biologie.genomique.kenetre.io.UnSynchronizedBufferedWriter
import fr.ens.biologie.genomique.kenetre.log.DummyLogger
import fr.ens.biologie.genomique.kenetre.log.StandardErrorLogger
import fr.ens.biologie.genomique.kenetre.log.FileLogger
import fr.ens.biologie.genomique.kenetre.storage.FileStorage
import fr.ens.biologie.genomique.kenetre.storage.FileGenomeDescStorage
import fr.ens.biologie.genomique.kenetre.storage.FileGenomeIndexStorage
import fr.ens.biologie.genomique.kenetre.storage.FileStorage
import fr.ens.biologie.genomique.kenetre.util.LocalReporter
import fr.ens.biologie.genomique.kenetre.util.StringUtils

include { read_conf; get_path; get_genome_desc } from './common.nf'


// The logger to use
logger = new StandardErrorLogger("stderr", [:])
//logger = new DummyLogger()


def create_mapper_instance(mapperName, tmpDir, binaryDir, mapperVersion, mapperFlavor) {

    mapperBuilder = new MapperBuilder(mapperName)
    mapperBuilder.withLogger(logger)

    if (tmpDir != null && !tmpDir.isEmpty()) {
        mapperBuilder.withTempDirectory(tmpDir)
    }

    if (binaryDir != null && !binaryDir.isEmpty()) {
        mapperBuilder.withExecutablesTempDirectory(binaryDir)
    }

    mapper = mapperBuilder.build()
    mapperInstanceBuilder = new MapperInstanceBuilder(mapper)
    

    if (mapperVersion != null && !mapperVersion.isEmpty()) {
        mapperInstanceBuilder.withMapperVersion(mapperVersion)
    }

    if (mapperFlavor != null && !mapperFlavor.isEmpty()) {
        mapperInstanceBuilder.withMapperFlavor(mapperFlavor)
    }

    return mapperInstanceBuilder.withUseBundledBinaries(true).build()
}

def compute_index(genomeFile, outIndexFile, mapperInstance, indexerArguments, cpus, workDir) {

    // Uncompress genome if necessary
    genomeCompression = CompressionType.getCompressionTypeByFile(genomeFile)
    inFile = null
    if (genomeCompression != CompressionType.NONE) {
        inFile = file(workDir + '/genome.fa').toFile()
        FileUtils.copy(genomeCompression.open(genomeFile), CompressionType.NONE.create(inFile))
    } else {
        inFile = genomeFile
    }

    mapperInstance.makeArchiveIndex(inFile, outIndexFile, indexerArguments, cpus)
}

def dirFile(dirPath) {

    if (dirPath != null) {
        return file(dirPath).toFile()
    }

    return null
}

process EOULSAN_INDEX {

    maxForks 1
    cpus Runtime.runtime.availableProcessors()
    publishDir( "${params.outdir}/mapping", mode: 'copy' )
    
    input:
    val genome
    val mapperName
    val mapperVersion
    val mapperFlavor
    val storages
    val tmpDir
    val binaryDir
    val indexerArguments

    output:
    path('index.zip')

    exec:

    //genomeFile = file(genome).toFile()
    genomeFile = get_path(genome.toString(), storages)

    // Get out file object
    outIndexFile = task.workDir.resolve("index.zip").toFile()

    // Get mapper instance
    mapperInstance = create_mapper_instance(mapperName, dirFile(tmpDir), dirFile(binaryDir), mapperVersion, mapperFlavor)

    // A genome storage exists ?
    if (storages.containsKey("main.genome.mapper.index.storage.path")) {

        gd = get_genome_desc(genomeFile.toString(), storages)

        gis = FileGenomeIndexStorage.getInstance(storages["main.genome.mapper.index.storage.path"], logger)

        additionalDescription = [:]
        if (!indexerArguments.isEmpty()) {
            additionalDescription["indexer.arguments"] = indexerArguments.trim()
        }
        result = gis.get(mapperInstance, gd, additionalDescription)

        if (result != null) {
            // An index already exist

            Files.createSymbolicLink(outIndexFile.toPath(), result.toPath())
            return
        } else {
            // No existing index, must compute it
            compute_index(genomeFile, outIndexFile, mapperInstance, indexerArguments, task.cpus, task.workDir)

            // Save index in storage
            gis.put(mapperInstance, gd, additionalDescription, outIndexFile)
        }
    } else {

        // No index storage just compute index
        compute_index(genomeFile, outIndexFile, mapperInstance, indexerArguments, task.cpus, task.workDir)
    }
}

process EOULSAN_MAPPING {

    maxForks 1
    cpus Runtime.runtime.availableProcessors()
    publishDir( "${params.outdir}/mapping", mode: 'copy' )
    
    input:
    tuple val(inFastq), val(index)
    // val index
    // val inFastq
    val mapperName
    val mapperVersion
    val mapperFlavor
    val tmpDir
    val binaryDir
    val mappersArguments
 
    output:
    path "${inFastq.baseName}.sam"
 
    exec:
    println("Lolo task.cpus for mapping: " + task.cpus)
    // Convert inFastq to File object
    inFastqFile = file(inFastq).toFile()
    print(inFastqFile)
    // Convert genome to File object
    indexZipFile = file(index)

    // Get out file object
    outSAMFile = task.workDir.resolve("${inFastq.baseName}.sam")

    // Define index directory
    indexDir = new File(filenameWithoutExtension(indexZipFile.toUri().getPath()))

    // Define the reporter
    reporter = new LocalReporter()
    counterGroup = "reads_mapping"

    // Get mapper instance
    mapperInstance = create_mapper_instance(mapperName, dirFile(tmpDir), dirFile(binaryDir), mapperVersion, mapperFlavor)

    // Create the MapperIndex object
    mapperIndex = mapperInstance.newMapperIndex(indexZipFile.toFile(), indexDir);

    fileMapping = mapperIndex.newFileMapping(FastqFormat.FASTQ_SANGER, mappersArguments,
            task.cpus, false, reporter, counterGroup);

    logFile = new File(outSAMFile.toString() + ".out")
    errorFile = new File(outSAMFile.toString() + ".err")

    mapperProcess = null
    inCT = CompressionType.getCompressionTypeByFile(inFastqFile)
    if (inCT == CompressionType.NONE) {
        mapperProcess = fileMapping.mapSE(inFastqFile, errorFile, logFile)
    } else {
        mapperProcess = fileMapping.mapSE(inCT.open(inFastqFile), errorFile, logFile)
    }

    // Parse output of the mapper
    MapperUtils.writeMapperOutputToFile(mapperProcess.getStout(), outSAMFile.toFile(), reporter, counterGroup, logger)

    // Wait the end of the process and do cleanup
    mapperProcess.waitFor()

    // TODO remove the index directory at the end of the workflow

}
