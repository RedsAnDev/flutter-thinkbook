import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

import '../calendar/_init.dart' as calendar;

class DBMSProvider {
  static final List initEntity = [calendar.DBModelCalendar.initDB];
  static final List initDataset = [calendar.DBModelCalendar.initData];

  static final String _nameDBData = "core.db";
  static final DBMSProvider db = DBMSProvider._();

  Database _database;

  DBMSProvider();

  DBMSProvider._();

  Future<Database> get database async {
    if (_database != null) return _database;
    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  // Creazione DB e tabelle
  initDB() async {
    String path=await _create_file_db();
    return await openDatabase(path, version: 1, onOpen: (Database db) async {
      await clearDB(null,dbObj:db);
    }, onCreate: (Database db, int version) async{
      await _createDB(db);
    });
  }

  /// Utility interna per eliminare il database
  _dropTableDB(obj, {Database dbObj,forceCreateFile: false}) async {
    if (forceCreateFile) {
      var path = await _create_file_db();
    }
    initEntity.forEach((functionInit) async {
      final sql=functionInit();
      final db = dbObj!=null?dbObj:await obj.database;
      try {
        print(sql);
        print("Tentativo drop table ${sql["table"]}");
        var test_2 = await db.rawQuery("DROP TABLE ${sql["table"]}");
      } catch (e) {
        print("ERROR IS [${sql["table"]}]");
        print(e);
      }
    });
  }

  _createDB(obj, {Database dbObj}) async {
    bool create;
    initEntity.forEach((functionInit) async {
      final sql=functionInit();
      final db = dbObj!=null?dbObj:await obj.database;
      try {
        await db.rawQuery("SELECT * FROM ${sql["table"]} LIMIT 1");
        create = false;
      } catch (e) {
        print("Non esiste la tabella ${sql["table"]}");
        print(e);
        create = true;
      }
      if (create) {
        try {
          print("Tentativo create table ${sql["table"]}");
          var buffer = await db.rawQuery(sql["create"]);
          print("Tentativo completato come $buffer");
        } catch (e) {
          print("Impossibile creare query");
          print(e);
        }
      }
    });
  }

  _create_file_db() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _nameDBData);

    ///Creazione file se necessario
    if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
      ByteData data = await rootBundle.load(path);
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await new File(path).writeAsBytes(bytes);
    }
    return path;
  }
  /// Rimuove tutte le tabelle presenti e le ricrea
  clearDB(db,{Database dbObj}) async {
    await _dropTableDB(db,dbObj: dbObj, forceCreateFile: true);
    await _createDB(db,dbObj: dbObj);
  }

  newObj(Map kwargs) async {
    print("KWARGS IS $kwargs");
    if (kwargs["query"] == null || kwargs["values"] == null) return null;
    final db = await database;
    var raw = await db.rawInsert(kwargs["query"], kwargs["values"]);
    return raw;
  }

  updateObj(tablename, {obj, where, whereArgs}) async {
    final db = await database;
    var res = await db.update(tablename, obj.toMap(),
        where: where, whereArgs: whereArgs);
    return res;
  }

  getObj(tablename,
      {distinct,
      columns,
      where,
      whereArgs,
      groupBy,
      having,
      orderBy,
      limit,
      offset}) async {
    final db = await database;
    var res = [];
    if (columns != null || where != null || whereArgs != null)
      res = await db.query(tablename,
          distinct: distinct,
          columns: columns,
          where: where,
          whereArgs: whereArgs,
          groupBy: groupBy,
          having: having,
          orderBy: orderBy,
          limit: limit,
          offset: offset);
    else
      res = await db.query(tablename);
    return res;
  }

  Future<List> getAllObj(tablename) async {
    final db = await database;
    var res = await db.query(tablename);
    return res;
  }

  deleteObj(tablename, {where, whereArgs}) async {
    final db = await database;
    return db.delete(tablename, where: where, whereArgs: whereArgs);
  }

  deleteAll(tablename) async {
    final db = await database;
    db.rawDelete("Delete * from " + tablename);
  }
}

abstract class DBMSModel {
  static String modelTableName;

  DBMSModel() {}

  factory DBMSModel.fromMap(_) {}

  static insert([db, DBMSModel obj, String fields, List values]) async {
    var index = 0;
    List<String> buffer = [];
    while (index < values.length) {
      buffer.add("?");
      index++;
    }
    await db.newObj({
      "query": "INSERT Into $DBMSModel ($fields)"
          " VALUES (${buffer.join(",")})",
      "values": values
    });
  }

  static getAll(db) async {
    var buffer = await db.getObj(modelTableName);
    return buffer.map((c) => DBMSModel.fromMap(c)).toList();
  }

  static query({db, String whereClause, List whereArgs}) async {
    var buffer = await db.getObj(modelTableName,
        where: whereClause, whereArgs: whereArgs);
    return buffer.map((c) => DBMSModel.fromMap(c)).toList();
  }

  static getByID(db, String idNode) async {
    return query(db: db, whereClause: "id = ?", whereArgs: [idNode]);
  }

  static getByIDList(db, List<String> idNode) async {
    String where = "";
    idNode.forEach((element) {
      where += " OR id = ?";
    });
    where = where.substring(4);
    return query(db: db, whereClause: where, whereArgs: idNode);
  }

  static delete(db, {id}) async {
    var buffer;
    if (id == null)
      buffer = await db.deleteAll(modelTableName);
    else
      buffer = await db.deleteObj(modelTableName, id: id);
    return buffer;
  }

  static update(db, item) async {
    var buffer = await db.updateObj(modelTableName,
        obj: item, where: "id = ?", whereArgs: [item.id]);
    return buffer;
  }

  Map<String, dynamic> toMap() {}
}
