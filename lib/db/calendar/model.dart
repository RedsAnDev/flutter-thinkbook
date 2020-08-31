import 'package:flutter/services.dart';

import 'enum.dart';
import '../orm/utility.dart' as util;
class DBModelCalendar {
  static final String modelTableName = "Calendar";
  String title, id;
  bool sync, visible, blocked;
  EnumPlatform platform;

  DBModelCalendar({this.id,this.title,this.platform,this.sync,this.visible,this.blocked});

  static initDB() {
    return {
      "table": modelTableName,
      "create": "CREATE TABLE $modelTableName ("
          "id TEXT PRIMARY KEY,"
          "title TEXT NULL,"
          "platform TEXT NULL,"
          "sync INTEGER DEFAULT 0,"
          "visible INTEGER DEFAULT 0,"
          "blocked INTEGER DEFAULT 1);"
    };
  }
  static initData(db) async {
    var file_path = 'data/init_data/node_model.csv';
    var content = await rootBundle.loadString(file_path);
    util.clusterDataset obj = util.clusterDataset.formatCSV(content);
    obj.dataset["src"].keys.forEach((k) {
      DBModelCalendar buffer = DBModelCalendar.fromMap(obj.dataset["src"][k]);
      insert(db, buffer);
    });
  }


  factory DBModelCalendar.fromMap(json) {
    try {
      return new DBModelCalendar(
        id: json["id"].toString().trim(),
        title: json["nodeName"].toString().trim(),
        platform: json["type"].toString().trim(),
        sync: json["macAddr"].toString().trim().toUpperCase(),
        visible: json["visible"].toString().trim() == "1",
        blocked: json["blocked"].toString().trim() == "1"),
      );
    } catch (e) {
      return null;
    }
  }
}
