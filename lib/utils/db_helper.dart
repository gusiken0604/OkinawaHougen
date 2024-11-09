import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

const jsonUrl = 'https://raw.githubusercontent.com/gusiken0604/okinawahougen/master/lib/utils/hougen.json';

class DBHelper {
  static Database? _db;

  // データベースインスタンスを取得するシングルトンパターン
  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  // データベースの初期化とテーブルの作成
  static Future<Database> _initDb() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "okinawahougen.db");

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS newHougen1001 (
            id INTEGER PRIMARY KEY,
            hougen TEXT,
            japanese TEXT,
            category TEXT,
            usage_example TEXT
          )
        ''');
        print("newHougen1001テーブルを作成しました");
      },
    );
  }

  // JSONデータを取得
  static Future<List<Map<String, dynamic>>> fetchHougenDataFromJson() async {
    print("JSONデータを取得中...");
    try {
      final response = await http
          .get(Uri.parse(jsonUrl))
          .timeout(Duration(seconds: 10), onTimeout: () {
        throw Exception('リクエストがタイムアウトしました');
      });

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        print("JSONデータの取得に成功しました。データ件数: ${jsonData.length}");
        return List<Map<String, dynamic>>.from(jsonData);
      } else {
        print("JSONデータの取得に失敗しました。ステータスコード: ${response.statusCode}");
        throw Exception('Failed to load JSON data');
      }
    } catch (e) {
      print("fetchHougenDataFromJson エラー: $e");
      return [];
    }
  }

  // JSONデータをSQLiteデータベースにインポート
  static Future<void> updateDatabaseWithJsonData() async {
    final db = await DBHelper.db;
    try {
      List<Map<String, dynamic>> hougenData = await fetchHougenDataFromJson();
      print("データベースにインポートするデータの件数: ${hougenData.length}");

      if (hougenData.isNotEmpty) {
        await db.transaction((txn) async {
          for (var item in hougenData) {
            item = Map<String, dynamic>.from(item);
            item.remove('last_updated'); // 不要なキーを削除

            // 空のフィールドにデフォルト値を設定
            item['category'] = item['category']?.isNotEmpty == true ? item['category'] : 'N/A';
            item['usage_example'] = item['usage_example']?.isNotEmpty == true ? item['usage_example'] : 'N/A';

            try {
              await txn.insert(
                'newHougen1001',
                item,
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            } catch (e) {
              print("データ挿入エラー: $e データ: ${item['id']}");
            }
          }
        });
        print("データベースをJSONデータで更新しました");
      } else {
        print("インポートするデータがありません");
      }
    } catch (e) {
      print("updateDatabaseWithJsonData エラー: $e");
    }
  }

  // データベースからデータを取得
  static Future<List<Map<String, dynamic>>> fetchDataFromDatabase() async {
    final db = await DBHelper.db;
    List<Map<String, dynamic>> data = await db.query('newHougen1001');
    print("データベースから取得したデータ件数: ${data.length}");
    return data;
  }
}