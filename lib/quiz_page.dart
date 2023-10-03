import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
//import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';

Database? db; // データベースを保持するためのグローバル変数

Future<void> initDb() async {
  try {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "okinawahougen.db"); //assets/okinawahougen.db"

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
    print("56initDbが完了しました");

  } catch (e) {
    print("initDb エラー: $e");
  }
}

Future<void> readDatabase() async {
  if (db != null) {
    // すでにデータベースが開かれていると仮定（dbはnullでないと仮定）
    final List<Map<String, dynamic>> maps = await db!.query('newHougen1001');

    for (var i = 0; i < maps.length; i++) {
      // これで各レコードがコンソールに出力されます
    }
  }
}

Future<List<Map<String, dynamic>>> fetchDataFromDatabase() async {
  List<Map<String, dynamic>> maps = [];
  if (db != null) {
    maps = await db!.query('newHougen1001');
  }
  return maps;
}

// Future<String> fetchDataFromDatabase() async {
//   if (db != null) {
//     final List<Map<String, dynamic>> maps = await db!.query('newHougen1001');
//     print("取得したデータ: $maps");
//     if (maps.isNotEmpty) {
//       print("取得した最初のレコードのカラム名: ${maps[0].keys}");  // この行を追加
//
//       String data = "";
//       for (var i = 0; i < maps.length; i++) {
//         data += "id: ${maps[i]['id'] ?? 'null'}, hougen: ${maps[i]['hougen'] ?? 'null'}\n";
//       }
//       return data;
//     } else {
//       return "データベースは空です";
//     }
//   } else {
//     return "データベースが初期化されていません";
//   }
// }

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Map<String, dynamic>>? databaseData;

  @override
  void initState() {
    super.initState();
    initDb().then((_) async {
      List<Map<String, dynamic>> fetchedData = await fetchDataFromDatabase();
      setState(() {
        databaseData = fetchedData;
      });
    }).catchError((error) {
      print("initState エラー: $error");
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  //   initDb().then((_) async { // initDbが完了したら
  //     String fetchedData = await fetchDataFromDatabase(); // データベースを読む
  //     print("UIに表示するデータ: $fetchedData");  // この行を追加
  //     setState(() {
  //       databaseData = fetchedData; // 状態を更新
  //     });
  //   }).catchError((error) {
  //     print("initState エラー: $error");
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
        title: Text(
          '沖縄方言',
          style: TextStyle(
            fontSize: 40,
          ),
        ),
      ),
      body: databaseData == null
          ? CircularProgressIndicator()
          : ListView.builder(
        itemCount: databaseData!.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(databaseData![index]['hougen'] ?? ''),
            subtitle: Text(databaseData![index]['japanese'] ?? ''),
          );
        },
      ),
    );
  }
}

//   String? databaseData; // データベースのデータを格納する変数
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme
//             .of(context)
//             .colorScheme
//             .inversePrimary,
//         title: Text(
//           '沖縄方言',
//           style: TextStyle(
//             fontSize: 40,
//           ),
//         ),
//       ),
//       body: databaseData == null ?
//       CircularProgressIndicator() : // ロード中
//       Text(
//         'データ:\n$databaseData',
//         style: TextStyle(fontSize: 16),
//       ),
//     );
//   }
// }