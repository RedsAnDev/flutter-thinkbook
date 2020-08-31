toDate(String value, {def: "0000-00-00 00:00:00Z", fmt: "iso"}) {
  var temp = null;
  switch (fmt) {
    case "iso":
      temp = value;
      break;
    default:
      return def;
      break;
  }
  try {
    var buffer = DateTime.parse(temp);
    return buffer;
  } catch (e) {
    return null;
  }
}

class clusterDataset {
  Map dataset;

  clusterDataset() {
    dataset = {"src": null, "scheme": null};
  }

  clusterDataset.formatCSV(content) {
    dataset = {"src": null, "scheme": null};
    readFromContent(content, "csv");
  }

  readFromContent(content, String format) {
    var parsing = null;
    switch (format.toLowerCase()) {
      case "csv":
        parsing = _formatCSV;
        break;
    }
    if (parsing == null) return null;
    content.toString().split("\n").forEach((line) {
      parsing({"line": line});
    });
  }

  ///
  /// Ampliamento del dataset tramite formato CSV
  _formatCSV(Map kwargs) {
    String separator = ",";
    String comment = "#";
    var buffer = {};
    List line;
    if (kwargs["separator"] != null) {
      separator = kwargs["separator"];
    }
    if (kwargs["comment"] != null) {
      separator = kwargs["comment"];
    }
    if (kwargs["line"] != null) {
      line = kwargs["line"].split(separator);
    }
    if (line.length == 0) return null;
    var counter = 0;
    if (line[0][0] == comment) {
      //Creo lo schema in dataset
      if (dataset["scheme"] == null) {
        dataset["scheme"] = {};
        dataset["src"] = {};
      }
      line.forEach((element) {
        dataset["scheme"][counter.toString()] = element.trim();
        if (dataset["scheme"][counter.toString()]
            .substring(0, 1)
            .contains(comment))
          dataset["scheme"][counter.toString()] = dataset["scheme"]
          [counter.toString()]
              .replaceFirst(comment, "")
              .trim();
        counter++;
      });
    } else {
      var counter_line = dataset["src"].keys.length;
      var key;
      line.forEach((e) {
        key = dataset["scheme"][counter.toString()];
        if (dataset["src"][counter_line] == null)
          dataset["src"][counter_line] = {};
        dataset["src"][counter_line][key] = e.toString().trim();
        counter++;
      });
    }
  }
}
