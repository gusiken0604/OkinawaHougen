import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
//import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';

Database? db; // データベースを保持するためのグローバル変数

Future<void> initDb() async {
  var databasesPath = await getDatabasesPath();
  var path = join(databasesPath, "assets/okinawahougen.db");

  var exists = await databaseExists(path);

  if (!exists) {
    // DBが存在しない場合の処理
    // アプリケーションを最初に起動したときのみ発生するはずです
    print("アプリケーションを最初に起動したときのみ発生Creating new copy from asset");
// 親ディレクトリが存在することを確認する
    try {
      await Directory(dirname(path)).create(recursive: true);
    } catch (_) {}
    // アセットからコピー
    ByteData data = await rootBundle.load(join("assets", "example.db"));
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

// 書き込まれたバイトを書き込み、フラッシュする
    await File(path).writeAsBytes(bytes, flush: true);
  } else {
    // DBが存在する場合の処理
    print("DBが存在する場合の処理Opening existing database");
  }
  // DBファイルを開く
  db = await openDatabase(path, readOnly: true);
}

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  @override
  void initState() {
    super.initState();
    initDb(); // initState内で非同期処理を呼び出す
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          '沖縄方言',
          style: TextStyle(
            fontSize: 40,
          ),
        ),
      ),
      body: Center(),
    );
  }
}

// class QuizPage extends StatelessWidget {
//   const QuizPage({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//
//
//     return Scaffold(
//         appBar: AppBar(
//           backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//           title: Text(
//             '沖縄方言',
//             style: TextStyle(
//               fontSize: 40,
//             ),
//           ),
//         ),
//       body: Center(
//              ),
//     );
//   }
// }