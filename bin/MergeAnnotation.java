package fr.ens.biologie.genomique.eoulsan.bio.kementad;

import static fr.ens.biologie.genomique.kenetre.io.CompressionType.open;
import static java.util.Objects.requireNonNull;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.Writer;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import com.google.common.collect.ArrayListMultimap;
import com.google.common.collect.Multimap;

import fr.ens.biologie.genomique.kenetre.KenetreException;
import fr.ens.biologie.genomique.kenetre.bio.GFFEntry;
import fr.ens.biologie.genomique.kenetre.bio.GenomicArray;
import fr.ens.biologie.genomique.kenetre.bio.GenomicInterval;
import fr.ens.biologie.genomique.kenetre.bio.io.GFFReader;
import fr.ens.biologie.genomique.kenetre.bio.io.GTFReader;
import fr.ens.biologie.genomique.kenetre.util.LocalReporter;
import fr.ens.biologie.genomique.kenetre.util.Reporter;

public class MergeAnnotation {

  // Key: transcriptId, Value: geneId
  final Map<String, String> transcriptParent = new HashMap<>();

  // Key: transcriptId, Value: exonId
  final Multimap<String, String> transcriptExons = ArrayListMultimap.create();

  // Key: exonId, Value: transcriptId
  final Multimap<String, String> exonParents = ArrayListMultimap.create();

  // Exons position on the genome
  final GenomicArray<String> genomeExons = new GenomicArray<>();

  // Key: exonId, Value: exon position
  final Map<String, GenomicInterval> exonIntervals = new HashMap<>();

  // Key: transcriptId, Value: number of exons for the transcript
  final Map<String, Integer> exonIdCounts = new HashMap<>();

  private void initGTF(File officialAnnotationGTFFile)
      throws KenetreException, IOException {

    try (GFFReader reader = new GTFReader(open(officialAnnotationGTFFile))) {

      for (GFFEntry entry : reader) {

        switch (entry.getType()) {

        case "gene":
          break;

        case "transcript":
          String geneId =
              entry.getAttributeValue("gene_id").replace("gene-", "");
          String transcriptId = entry.getAttributeValue("transcript_id");
          this.transcriptParent.put(transcriptId, geneId);
          break;

        case "exon":

          // Get transcriptId
          String transcriptId2 = entry.getAttributeValue("transcript_id");
          int exonCount = increment(this.exonIdCounts, transcriptId2);

          // Define exonId
          String exonId = entry.getAttributeValue("exon_id");
          if (exonId == null) {
            exonId = transcriptId2 + ".exon" + exonCount;
          }

          GenomicInterval exonInterval = new GenomicInterval(entry);

          this.genomeExons.addEntry(exonInterval, exonId);
          this.exonIntervals.put(exonId, exonInterval);

          this.transcriptExons.put(transcriptId2, exonId);
          this.exonParents.put(exonId, transcriptId2);
          break;

        }
      }
    }
  }

  private void renameGeneId(GFFEntry entry, Map<String, String> geneAliases) {

    String geneId = entry.getAttributeValue("gene_id");

    if (geneAliases.containsKey(geneId)) {
      entry.setAttributeValue("gene_id", geneAliases.get(geneId));
    }
  }

  private boolean renameGeneId(GFFEntry entry, Reporter reporter) {

    Set<String> matchingGeneIds = matchingGenes(entry, reporter);
    // System.out.println(matchingGeneIds);
    // TODO Handle case with more than one match

    // No match found
    if (matchingGeneIds == null || matchingGeneIds.isEmpty()) {
      return false;
    }

    String newGeneId = null;

    switch (matchingGeneIds.size()) {

    case 0:
      throw new IllegalStateException("No match found");
    case 1:
      newGeneId = matchingGeneIds.iterator().next();
      break;
    default:
      newGeneId = String.join(" ", matchingGeneIds);
      // System.out.println(matchingGeneIds.size() + " matches for entry");
      // return false;
    }

    if (newGeneId != null) {
      entry.setAttributeValue("gene_id", newGeneId);
    }

    return true;
  }

  private Set<String> matchingGenes(GFFEntry entry, Reporter reporter) {

    Map<GenomicInterval, Set<String>> matches =
        this.genomeExons.getEntries(new GenomicInterval(entry));

    if (matches == null) {
      matches = Collections.emptyMap();
    }

    Set<String> exons = new HashSet<>();
    for (Set<String> values : matches.values()) {
      exons.addAll(values);
    }

    Set<String> transcripts = new HashSet<>();
    for (String exonId : exons) {
      transcripts.addAll(this.exonParents.get(exonId));
    }

    Set<String> genes = new HashSet<>();
    for (String transcriptId : transcripts) {
      genes.add(this.transcriptParent.get(transcriptId));
    }

    reporter.incrCounter("test", genes.size() + " match(es)", 1);

    return genes;
  }

  private static int increment(Map<String, Integer> map, String key) {

    requireNonNull(map);

    int value = (map.containsKey(key) ? map.get(key) : 0) + 1;
    map.put(key, value);

    return value;
  }

  public void process(File inputGTF, Writer writer) throws IOException {

    Map<String, String> geneAliases = new HashMap<>();
    Reporter reporter = new LocalReporter();

    try (GFFReader reader = new GTFReader(open(inputGTF))) {

      for (final GFFEntry entry : reader) {

        if (!entry.isAttribute("gene_id")) {
          continue;
        }

        // Process only RLOC_00000001 entries
        // String geneId = entry.getAttributeValue("gene_id");
        // if (!"RLOC_00000001".equals(geneId)) {
        // continue;
        // }

        switch (entry.getType()) {

        case "gene":
          String geneId = entry.getAttributeValue("gene_id");
          processGene(entry, reporter);
          String newGeneId = entry.getAttributeValue("gene_id");
          if (!geneId.equals(newGeneId)) {
            geneAliases.put(geneId, newGeneId);
          }

          // System.out.println(entry);
          break;

        case "transcript":
          processTranscript(entry, geneAliases);
          // System.out.println(entry);
          break;

        case "exon":
          processExon(entry, geneAliases);
          // System.out.println(entry);
          break;

        case "CDS":
          processCDS(entry, geneAliases);
          // System.out.println(entry);
          break;

        case "five_prime_UTR":
        case "three_prime_UTR":
          processUTR(entry, geneAliases);
          // System.out.println(entry);
          break;

        default:
          break;

        }

        // System.out.println(entry.toGTF());
        writer.write(entry.toGTF() + '\n');
      }
    }

    // System.out.println();
    // System.out.println(reporter);
  }

  private void processGene(GFFEntry entry, Reporter reporter) {

    String geneId = entry.getAttributeValue("gene_id");

    if (!renameGeneId(entry, reporter) && entry.isAttribute("genefeature_ids")) {
      entry.setAttributeValue("geneIDs",
          entry.getAttributeValue("genefeature_ids").replace('|', ','));
    }

    entry.removeAttribute("genefeature_ids");
    entry.removeAttribute("feature_id");
    entry.removeAttribute("transcripts");

    entry.setAttributeValue("Note", geneId);
    entry.setAttributeValue("gene_biotype", "protein_coding");
  }

  private void processTranscript(GFFEntry entry,
      Map<String, String> geneAliases) {

    String geneId = entry.getAttributeValue("gene_id");
    renameGeneId(entry, geneAliases);

    entry.removeAttribute("genefeature_ids");
    entry.removeAttribute("feature_parent");
    entry.removeAttribute("feature_id");
    entry.removeAttribute("genefeature_id");

    entry.setAttributeValue("Note", geneId);
  }

  private void processExon(GFFEntry entry, Map<String, String> geneAliases) {

    String geneId = entry.getAttributeValue("gene_id");
    renameGeneId(entry, geneAliases);

    String exonId = entry.getAttributeValue("feature_id");
    entry.setAttributeValue("exon_id", exonId);
    entry.removeAttribute("feature_id");
    entry.removeAttribute("feature_parent");
    entry.setAttributeValue("Note", geneId);
  }

  private void processCDS(GFFEntry entry, Map<String, String> geneAliases) {

    renameGeneId(entry, geneAliases);

    String cdsId = entry.getAttributeValue("feature_id");
    entry.setAttributeValue("Note", cdsId);
    entry.removeAttribute("feature_id");
    entry.removeAttribute("feature_parent");
  }

  private void processUTR(GFFEntry entry, Map<String, String> geneAliases) {

    String geneId = entry.getAttributeValue("gene_id");
    renameGeneId(entry, geneAliases);

    entry.removeAttribute("feature_id");
    entry.removeAttribute("feature_parent");

    entry.setAttributeValue("Note", geneId);
  }

  //
  // Main
  //

  /**
   * Execute the script
   * @param officialGTF official GTF file
   * @param inputGTF input GTF file
   * @param outputGTF outour GTF file
   * @throws KenetreException if an error occurs while reading official
   *           annotation
   * @throws IOException if an error occurs while processing data
   */
  private static void execute(File officialGTF, File inputGTF, File outputGTF)
      throws KenetreException, IOException {

    MergeAnnotation o = new MergeAnnotation();
    o.initGTF(officialGTF);

    // TODO double pass to avoid case where gene are after reference to the gene
    try (Writer writer = new FileWriter(outputGTF)) {
      o.process(inputGTF, writer);
    }
  }

  /**
   * Main method.
   * @param args command line arguments
   */
  public static void main(String[] args) {

    if (args.length != 2) {
      System.err.println("Syntax merge-annotation.sh reference.gtf input.gtf");
      System.exit(1);
    }

    File officialGTF = new File(args[0]);
    File inputGTF = new File(args[1]);
    File outputGTF = new File("/dev/stdout");

    try {
      execute(officialGTF, inputGTF, outputGTF);
    } catch (IOException | KenetreException e) {
      System.err.println("ERROR: " + e.getMessage());
      System.err.println();
      System.err.println("=== Stack trace ===");
      e.printStackTrace();
    }

  }

  public static void mainOld(String[] args)
      throws KenetreException, IOException {

    File officialGTF = new File(
        "/home/jourdren/shares-net/ressources/sequencages/gtf/dujardini_hiC_liftoff.gtf.bz2");
    File inputGTF = new File(
        "/home/jourdren/shares-net/sequencages/analyses/RETARDannotHE_A2022/2MM/isoquant_rnabloom/"
            + "rnabloom.transcripts_polished_with_SR_agatComp_gffread_clustersMKZ.gtf");

    File ouputGTF = new File("/home/jourdren/Bureau/matching.gtf");

    // MergeAnnotation o = new MergeAnnotation();
    // o.initGTF(officialGTF);
    //
    // // TODO double pass to avoid case where gene are after reference to the
    // gene
    // try (Writer writer =
    // new FileWriter()) {
    // o.process(inputGTF, writer);
    // }

  }

}
