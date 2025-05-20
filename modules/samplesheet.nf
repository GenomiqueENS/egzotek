import java.nio.file.Paths

def readCSV(samplesheetFile) {

    // Read all CSV lines
    def lignes = samplesheetFile.readLines('UTF-8')

    if (lignes.isEmpty()) {
        assert "Empty sample sheet file."
    }

    // The first line contains the headers
    def headers = lignes[0].split(',')

    def result = []

    // Parse next lines
    lignes.tail().each { ligne ->
        def valeurs = ligne.split(',')

        // Create a map {header: valeur}
        def record = [ : ]
        headers.eachWithIndex { header, index ->
            record[header.trim()] = (index < valeurs.size()) ? valeurs[index].trim() : null
        }

        result.add(record)
    }

    return result
}

def createFastqChannelFromSampleSheet(samplesheetFile) {

    def samplesheetPath = null
    if (samplesheetFile.class == String) {
        samplesheetPath = Paths.get(samplesheetFile)
    } else {
        samplesheetPath = samplesheetFile
    }

    def samplesheetDir = samplesheetPath.getParent()
    def entries = readCSV(samplesheetPath)

    paths = []

    for (it in entries) {
        s = it['fastq']
        p = null
        if (!s.startsWith('/')) {
            p = Paths.get(samplesheetDir.toString(), s)
        } else {
            p =  Paths.get(s)
        }
        paths.add(p)
    }
    return Channel.fromList(paths)
}


// Fonction qui convertit une Liste en YAML
String listToYaml(List list, int indentLevel = 0) {
    String yaml = ''
    String indent = '  ' * indentLevel  // 2 espaces par niveau

    list.each { item ->
        if (item instanceof Map) {
            yaml += "${indent}- "
            yaml += mapToYaml(item, indentLevel + 1)
        } else if (item instanceof List) {
            yaml += "${indent}- "
            yaml += listToYaml(item, indentLevel + 1)
        } else {
            yaml += "${indent}- \"${item}\"\n"
        }
    }

    return yaml
}

// Fonction auxiliaire pour convertir une Map
String mapToYaml(Map map, int indentLevel = 0) {
    String yaml = ''
    String indent = '  ' * indentLevel

    map.each { key, value ->
        if (value instanceof Map) {
            yaml += "${indent}\"${key}\":\n"
            yaml += mapToYaml(value, indentLevel + 1)
        } else if (value instanceof List) {
            yaml += "${indent}\"${key}\":\n"
            yaml += listToYaml(value, indentLevel + 1)
        } else {
            yaml += "\"${key}\": ${value}\n"
        }
    }

    return yaml
}

def csv2yaml(csvFile, yamlFile) {

    def samplesheetPath = null
    if (csvFile.class == String) {
        samplesheetPath = Paths.get(csvFile)
    } else {
        samplesheetPath = csvFile
    }

    def entries = readCSV(samplesheetPath)
    data = [:]

    for (it in entries) {
        condition = it['condition']
        if (!data.containsKey(condition)) {
            data[condition] = ["name": condition, "long read files": [], "labels": []]
        }

        fastqPath = it['fastq']
        bamPath = fastqPath.replace('.gz', '').replace('.fastq', '.bam')
        label = "Sample" + it['sample']

        data[condition]["long read files"].add(bamPath)
        data[condition]["labels"].add(label)
    }

    yamlMap = [["data format": "bam"]]
    data.each{entry -> yamlMap.add(entry.value)}

    // Write YAML output file
    yamlFile.withWriter { writer ->
        writer.write listToYaml(yamlMap)
    }

}


def createConditionChannelFromSampleSheet(samplesheetFile) {

    def samplesheetPath = null
    if (samplesheetFile.class == String) {
        samplesheetPath = Paths.get(samplesheetFile)
    } else {
        samplesheetPath = samplesheetFile
    }

    def samplesheetDir = samplesheetPath.getParent()
    def entries = readCSV(samplesheetPath)

    conditions = [:]

    // Fill the conditions map from sample sheet
    for (it in entries) {
        c = it['condition']
        s = it['fastq']
        p = null

        if (!conditions.containsKey(c)) {
            conditions.put(c, [])
        }
        paths = conditions[c]

        if (!s.startsWith('/')) {
            p = Paths.get(samplesheetDir.toString(), s)
        } else {
            p =  Paths.get(s)
        }

        paths.add(p)
    }

    // Create the Channel from the conditions map
    result = Channel.of()
    conditions.each { k, v ->
      l = [k]
      l.addAll(v)
      c = Channel.of(l)
      result = result.concat(c)
    }

    return result
}
