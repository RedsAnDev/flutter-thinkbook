import 'dart:io';
import 'package:path/path.dart';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBMSProvider {
  static final List initEntity = [
//    class model initDB
  ];
  static final List initDataset = [
//    class model initData
  ];

  static final String _nameDBGeodata = "geodata.db";
  static final DBMSProvider db = DBMSProvider._();

  Database _database;

  DBMSProvider._();

  Future<Database> get database async {
    if (_database != null) return _database;
    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  _create_file_db() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _nameDBGeodata);

    ///Creazione file se necessario
    if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
      ByteData data = await rootBundle.load(path);
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      var buffer = await new File(path).writeAsBytes(bytes);
      print("BUFFER IS" + buffer.toString());
    }
    print("PATH IS" + path.toString());
    return path;
  }

  /// Creazione del Database ed eventualmente del file DB
  createDB() async {
    ///Creazione file se necessario
    var path = _create_file_db();
    await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) {
      this._createDB(db);
    });
  }

  ///Creazione delle tabelle
  _createDB(obj, {forceCreateFile: false}) async {
    bool create;
    if (forceCreateFile) {
      var path = await _create_file_db();
    }
    initEntity.forEach((entity_function) async {
      final sql = entity_function();
      final db = await obj.database;
      try {
        var test = await db.rawQuery("SELECT * FROM ${sql["table"]} LIMIT 1");
        create = false;
      } catch (e) {
        print("Non esiste la tabella ${sql["table"]}");
        print(e);
        create = true;
      }
      if (create) {
        try {
          var buffer = await db.rawQuery(sql["create"]);
        } catch (e) {
          print("Impossibile creare query");
          print(e);
        }
      }
    });
  }

  /// Utility interna per eliminare il database
  _dropTableDB(obj, {forceCreateFile: false}) async {
    if (forceCreateFile) {
      var path = await _create_file_db();
    }
    initEntity.forEach((sql) async {
      final db = await obj.database;
      try {
        print("Tentativo drop table ${sql["table"]}");
        var test_2 = await db.rawQuery("DROP TABLE ${sql["table"]}");
      } catch (e) {
        print("ERROR IS [${sql["table"]}]");
        print(e);
      }
    });
  }

  //Creazione DB
  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _nameDBGeodata);
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) {
      _createDB(db);
    });
  }

  /// Effettua le procedure per recuperare i dati iniziali
  initData(db) {
    initDataset.forEach((func_initData) {
      func_initData(db);
    });
  }

  /// Rimuove tutte le tabelle presenti e le ricrea
  clearDB(db) async {
    await _dropTableDB(db, forceCreateFile: true);
    await _createDB(db, forceCreateFile: true);
  }

  newObj(Map kwargs) async {
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
