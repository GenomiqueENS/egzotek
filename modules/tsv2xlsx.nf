#!/usr/bin/env nextflow
nextflow.enable.dsl=2

import static fr.ens.biologie.genomique.kenetre.translator.TranslatorUtils.createDuplicatedEnsemblIdTranslator;

import fr.ens.biologie.genomique.kenetre.bio.io.TSVAnnotationMatrixReader
import fr.ens.biologie.genomique.kenetre.translator.CommonLinksInfoTranslator
import fr.ens.biologie.genomique.kenetre.translator.ConcatTranslator
import fr.ens.biologie.genomique.kenetre.translator.AnnotationMatrixTranslator
import fr.ens.biologie.genomique.kenetre.translator.TranslatorUtils
import fr.ens.biologie.genomique.kenetre.translator.io.XLSXTranslatorOutputFormat

include { read_conf; get_path; get_genome_desc; input_stream; output_stream } from './common.nf'

commonLinks = [
"GI" : 'http://www.ncbi.nlm.nih.gov/nuccore/${ID}',
"EnsemblID": 'http://www.ensembl.org/id/${ID}',
"Ensembl Gene ID" : 'http://www.ensembl.org/id/${ID}',
"Ensembl Transcript ID" : 'http://www.ensembl.org/id/${ID}',
"EntrezGeneID" : 'http://www.ncbi.nlm.nih.gov/sites/entrez?Db=gene&Cmd=ShowDetailView&TermToSearch=${ID}',
"EntrezGene ID " : 'http://www.ncbi.nlm.nih.gov/sites/entrez?Db=gene&Cmd=ShowDetailView&TermToSearch=${ID}',
"MGI ID" : 'http://www.informatics.jax.org/marker/${ID}',
"SGDID" : 'http://db.yeastgenome.org/cgi-bin/locus.pl?dbid=${ID}',
"Phatr2 Protein HyperLink" : 'http://genome.jgi-psf.org/cgi-bin/dispGeneModel?db=Phatr2&tid=${ID}',
"UCSC ID" : 'https://genome.ucsc.edu/cgi-bin/hgGene?org=&db=hg19&hgg_gene=${ID}',
"SGD Gene" : 'http://www.yeastgenome.org/locus/${ID}/overview',
"ZFIN ID" : 'https://zfin.org/${ID}'
]


def load_translator(annotFile) {

    did = createDuplicatedEnsemblIdTranslator()
    reader = new TSVAnnotationMatrixReader(input_stream(annotFile))
    matrix = reader.read()
    reader.close()
    translator = new CommonLinksInfoTranslator(
        new ConcatTranslator(did, new AnnotationMatrixTranslator(matrix)))

    commonLinks.each{ k, v -> translator.add(k, v) }

    return translator
}

process EOULSAN_TSV2XLSX {


 input:
    tuple val(inTsv), val(additionalAnnot)
    // val inTsv
    // val additionalAnnot
    val tmpDir
    val storages
 
    output:
    path "${inTsv.baseName}.xlsx"
 
    exec:

    // Convert inTsv to File object
    inTsvFile = file(inTsv)

    // Get annot file
    additionalAnnotFile = get_path(additionalAnnot.toString(), storages)

    // Get out file object
    outFile = task.workDir.resolve("${inTsv.baseName}.xlsx")

    // Create translator
    translator = load_translator(additionalAnnotFile)

    of = new XLSXTranslatorOutputFormat(output_stream(outFile), tmpDir.toFile())
    TranslatorUtils.addTranslatorFields(input_stream(inTsvFile), 0, translator, of)
}