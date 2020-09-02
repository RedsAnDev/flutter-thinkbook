import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:thinkbook/db/orm/dbms.dart';

import 'enum.dart';
import '../orm/utility.dart' as util;

class DBModelCalendar {
  static final String modelTableName = "Calendar";
  String title, id;
  bool synced, visible, blocked;
  EnumPlatform platform;

  String get getId => id;

  String get getTitle => title;

  bool get getSync => synced;

  bool get getVisible => visible;

  bool get getBlocked => blocked;

  EnumPlatform get getPlatform => platform;

  String get getPlatformString => enumProxy.readEnum(platform);

  DBModelCalendar(
      {this.id,
      this.title,
      this.platform,
      this.synced,
      this.visible,
      this.blocked});

  static initDB() {
    return {
      "table": modelTableName,
      "create": "CREATE TABLE $modelTableName ("
          "id TEXT PRIMARY KEY,"
          "title TEXT NULL,"
          "platform TEXT NULL,"
          "synced INTEGER DEFAULT 0,"
          "visible INTEGER DEFAULT 0,"
          "blocked INTEGER DEFAULT 1);"
    };
  }

  static initData(db) async {
    var file_path = 'data/init_data/sample.csv';
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
          title: json["title"].toString().trim(),
          platform: enumProxy.getEnum(json["platform"]),
          synced: json["synced"].toString().trim() == "1",
          visible: json["visible"].toString().trim() == "1",
          blocked: json["blocked"].toString().trim() == "1");
    } catch (e) {
      print("ERRORE DEL CAZZO $e");
      return null;
    }
  }

  static insert(db, DBModelCalendar obj) async {
    try {
      return await db.newObj({
        "query":
            "INSERT Into $modelTableName (id,title,synced,visible,blocked,platform)"
                " VALUES (?,?,?,?,?,?)",
        "values": [
          obj.id,
          obj.title,
          obj.synced ? 1 : 0,
          obj.visible ? 1 : 0,
          obj.blocked ? 1 : 0,
          enumProxy.readEnum(obj.platform)
        ]
      });
    } on DatabaseException {
      return await update(db, obj);
    } catch (e) {
      print("Errore in inserimento\n$e");
    }
    return null;
  }

  static getAll(db) async {
    var buffer = await db.getObj(modelTableName);
    return buffer.map((c) => DBModelCalendar.fromMap(c)).toList();
  }

  static _getBy({db, where, whereArgs}) async {
    var buffer =
        await db.getObj(modelTableName, where: where, whereArgs: whereArgs);
    return buffer.map((c) => DBModelCalendar.fromMap(c)).toList();
  }

  static getByID(db, String idNode) async {
    return await _getBy(db: db, where: "id = ?", whereArgs: [idNode]);
  }

  static getByIDList(db, List<String> idNode) async {
    String where = "";
    idNode.forEach((element) {
      where += " OR id = ?";
    });
    where = where.substring(4);
    var buffer =
        await db.getObj(modelTableName, where: where, whereArgs: idNode);
    return buffer.map((c) => DBModelCalendar.fromMap(c)).toList();
  }

  static delete(db, {id}) async {
    var buffer;
    if (id == null)
      buffer = await db.deleteAll(modelTableName);
    else
      buffer = await db.deleteObj(modelTableName, id: id);
    return buffer;
  }

  static update(db, DBModelCalendar item) async {
    var buffer = await db.updateObj(modelTableName,
        obj: item, where: "id = ?", whereArgs: [item.id]);
    return buffer;
  }

  static getOrCreate(db, String id, DBModelCalendar obj) async {
    var buffer = await getByID(db, id);
    if (buffer.length == 0) {
      await insert(db, obj);
      return obj;
    }
    return buffer[0];
  }

  Map<String, dynamic> toMap() {
    return {
      "id": this.id,
      "title": this.title,
      "platform": enumProxy.readEnum(this.platform),
      "synced": this.synced ? "1" : "0",
      "visible": this.visible ? "1" : "0",
      "blocked": this.blocked ? "1" : "0"
    };
  }
}

class DBModelEvent extends DBMSModel {
  static final String modelTableName = "Event";
  String id, idCalendar, title;
  DateTime dt_start, dt_end;
  Map payload;

  DBModelEvent(
      {this.id,
      this.idCalendar,
      this.title,
      this.payload,
      this.dt_start,
      this.dt_end})
      : super();

  static initDB() {
    return {
      "table": modelTableName,
      "create": "CREATE TABLE $modelTableName ("
          "id TEXT PRIMARY KEY,"
          "idCalendar TEXT NULL,"
          "title TEXT NULL,"
          "dt_start DATETIME NULL,"
          "dt_end DATETIME NULL,"
          "payload BLOB NULL);"
    };
  }

  static initData(db) async {
    var file_path = 'data/init_data/sample.csv';
    var content = await rootBundle.loadString(file_path);
    util.clusterDataset obj = util.clusterDataset.formatCSV(content);
    obj.dataset["src"].keys.forEach((k) {
      DBModelEvent buffer = DBModelEvent.fromMap(obj.dataset["src"][k]);
      insert(db, buffer);
    });
  }

  factory DBModelEvent.fromMap(json) {
    try {
      return new DBModelEvent(
          id: json["id"].toString().trim(),
          idCalendar: json["idCalendar"].toString().trim(),
          title: json["title"].toString().trim(),
          dt_start: DateTime.parse(json["dt_start"]),
          dt_end: json["dt_end"] != null
              ? DateTime.parse(json["dt_end"])
              : DateTime.fromMillisecondsSinceEpoch(
                  DateTime.parse(json["dt_start"]).millisecondsSinceEpoch +
                      1000 * 60 * 15),
          payload: json["payload"]);
    } catch (e) {
      return null;
    }
  }

  @override
  static insert(db, DBModelEvent obj) async {
    print(obj.dt_end);
    await db.newObj({
      "query":
          "INSERT Into $modelTableName (id,idCalendar,title,dt_start,dt_end,payload)"
              " VALUES (?,?,?,?,?,?)",
      "values": [
        obj.id,
        obj.idCalendar,
        obj.title,
        obj.dt_start.toString(),
        obj.dt_end.toString(),
        obj.payload
      ]
    });
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      "id": this.id,
      "idCalendar": this.idCalendar,
      "title": this.title,
      "dt_start": this.dt_start.toString(),
      "dt_end": this.dt_end.toString(),
      "payload": this.payload
    };
  }

  static Future getAllEvents(db) async {
    return await db.getObj(modelTableName);
  }

  static getByCalendarID(db, String id) async {
    return await db
        .getObj(modelTableName, where: "idCalendar = ?", whereArgs: [id]);
  }
}
