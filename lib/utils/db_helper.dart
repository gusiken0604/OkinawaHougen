import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

Database? db;

// JSONファイルのURL
const jsonUrl = 'https://raw.githubusercontent.com/gusiken0604/okinawahougen/master/lib/utils/hougen.json';

// データベースの初期化とテーブルの作成
Future<void> initDb() async {
  try {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "okinawahougen.db");

    // データベースを削除して再作成
    if (await databaseExists(path)) {
      await deleteDatabase(path);
      print("既存のデータベースを削除しました");
    }

    db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE newHougen1001 (
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

    print("initDbが完了しました");

    // データベース更新
    await updateDatabaseWithJsonData();

  } catch (e) {
    print("initDb エラー: $e");
  }
}

// JSONファイルから方言データを取得
Future<List<Map<String, dynamic>>> fetchHougenDataFromJson() async {
  print("JSONデータを取得中...");
  final response = await http.get(Uri.parse(jsonUrl));

  if (response.statusCode == 200) {
    List<dynamic> jsonData = json.decode(response.body);
    print("JSONデータの取得に成功しました。データ件数: ${jsonData.length}");
    return List<Map<String, dynamic>>.from(jsonData);  // リストとして処理
  } else {
    print("JSONデータの取得に失敗しました。ステータスコード: ${response.statusCode}");
    throw Exception('Failed to load JSON data');
  }
}

// JSONデータをSQLiteデータベースにインポート
Future<void> updateDatabaseWithJsonData() async {
  if (db == null) {
    print("データベースが初期化されていません");
    return;
  }

  try {
    List<Map<String, dynamic>> hougenData = await fetchHougenDataFromJson(); // リストとして取得
    print("データベースにインポートするデータの件数: ${hougenData.length}");

    if (hougenData.isNotEmpty) {
      await db!.transaction((txn) async {
        for (var item in hougenData) {
          item = Map<String, dynamic>.from(item);  // 各要素をMap<String, dynamic>として扱う
          item.remove('last_updated'); // last_updated キーを削除

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

// データベースからデータを取得する関数
Future<List<Map<String, dynamic>>> fetchDataFromDatabase() async {
  if (db == null) {
    print("データベースが初期化されていません");
    return [];
  }
  List<Map<String, dynamic>> data = await db!.query('newHougen1001');
  print("データベースから取得したデータ件数: ${data.length}");
  return data;
}