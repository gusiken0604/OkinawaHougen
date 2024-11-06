import 'dart:io';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Database? db;

// データベースを初期化し、ファイルを開く処理
Future<void> initDb() async {
  try {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "okinawahougen.db");

    var exists = await databaseExists(path);

    if (!exists) {
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      ByteData data = await rootBundle.load(join("assets", "okinawahougen.db"));
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      await File(path).writeAsBytes(bytes, flush: true);
    }

    db = await openDatabase(path, readOnly: true);
    print("initDbが完了しました");
  } catch (e) {
    print("initDb エラー: $e");
  }
}

// データベースからデータを取得する処理
Future<List<Map<String, dynamic>>> fetchDataFromDatabase() async {
  List<Map<String, dynamic>> maps = [];
  if (db != null) {
    maps = await db!.query('newHougen1001');
  }
  return maps;
}