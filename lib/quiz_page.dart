// ignore_for_file: avoid_print
//printの警告文を消す
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'gojuon_list.dart';
import 'romaji_to_katakana.dart';


Database? db; // データベースを保持するためのグローバル変数

Future<void> initDb() async {
  // データベースを開く処理
  try {
    // 例外処理
    var databasesPath = await getDatabasesPath(); // データベースのパスを取得
    var path =
        join(databasesPath, "okinawahougen.db"); //assets/okinawahougen.db"

    var exists = await databaseExists(path); // データベースがすでに存在しているかどうかを確認

    if (!exists) {
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      ByteData data = await rootBundle.load(join("assets", "okinawahougen.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

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

class QuizPage extends StatefulWidget {
  const QuizPage({Key? key}) : super(key: key);
  @override
  QuizPageState createState() => QuizPageState();
}

class QuizPageState extends State<QuizPage> {
  final ScrollController _controller = ScrollController(); // 追加
  List<Map<String, dynamic>>? databaseData;

  // カタカナからローマ字に変換する辞書を作成
  final Map<String, String> katakanaToRomaji = {};

  String selectedKana = ''; //選択されている50音の文字を保持
  // ローマ字からカタカナへのマッピング
String convertToKatakana(String input) {
  StringBuffer output = StringBuffer();
  for (var i = 0; i < input.length; i++) {
    String current = input[i];

    // 3文字の組み合わせをチェック
    if (i < input.length - 2) {
      String next = input.substring(i, i + 3);
      if (romajiToKatakana.containsKey(next)) {
        output.write(romajiToKatakana[next]);
        i += 2; // 3文字分処理したのでインデックスを2つ進める
        continue;
      }
    }

    // 2文字の組み合わせをチェック
    if (i < input.length - 1) {
      String next = input.substring(i, i + 2);
      if (romajiToKatakana.containsKey(next)) {
        output.write(romajiToKatakana[next]);
        i++; // 2文字分処理したのでインデックスを1つ進める
        continue;
      }
    }

    // 単一文字の変換
    if (romajiToKatakana.containsKey(current)) {
      output.write(romajiToKatakana[current]);
    }
  }
  return output.toString();
}

  Future<List<Map<String, dynamic>>> fetchDataFromDatabase() async {
    List<Map<String, dynamic>> maps = [];
    if (db != null) {
      // 選択されている50音の文字に基づいてフィルタリング
      if (selectedKana.isNotEmpty) {
        maps = await db!.query(
          'newHougen1001',
          where: "hougen LIKE ?",
          whereArgs: ['$selectedKana%'],
        );
      } else {
        maps = await db!.query('newHougen1001');
      }
    }
    return maps;
  }

  @override
  void initState() {
    super.initState();

    romajiToKatakana.forEach((key, value) {
      katakanaToRomaji[value] = key;
    });
    // デバッグ: katakanaToRomaji が正しく初期化されているか確認
    //print("katakanaToRomaji: $katakanaToRomaji");
      initDb().then((_) async {
    List<Map<String, dynamic>> fetchedData = await fetchDataFromDatabase();

    // データが取得できた場合のみ最初の行を削除
    if (fetchedData.isNotEmpty) {
      setState(() {
        // 最初の行を削除したデータで更新
        databaseData = fetchedData.sublist(1);
      });
    } else {
      // データが空の場合もセットし、空リストで表示
      setState(() {
        databaseData = [];
      });
    }
  }).catchError((error) {
    print("initState エラー: $error");
  });
}

  //   initDb().then((_) async {
  //     List<Map<String, dynamic>> fetchedData = await fetchDataFromDatabase();

  //     setState(() {
  //       databaseData = fetchedData;
  //     });
  //   }).catchError((error) {
  //     print("initState エラー: $error");
  //   });
  // }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: const Text(
        '沖縄方言',
        style: TextStyle(fontSize: 40),
      ),
    ),
    body: Row(
      children: [
        Expanded(
          child: databaseData == null
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  controller: _controller,
                  itemCount: databaseData!.length - 1,
                  separatorBuilder: (context, index) => const Divider(color: Colors.grey),
                  itemBuilder: (context, index) {
                     final actualIndex = index + 1; // インデックスを1つずらして最初の行をスキップ
                    return ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(convertToKatakana(databaseData![index]['hougen'] ?? '')),
                              Text(
                                //'ID: ${databaseData![index]['id'].toString()}',
                                 'ID: ${databaseData![index]['id']}', // データベースから取得したIDを直接表示
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      subtitle: Text(databaseData![index]['japanese'] ?? ''),
                    );
                  },
                ),
        ),
//  Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: const Text(
//           '沖縄方言',
//           style: TextStyle(
//             fontSize: 40,
//           ),
//         ),
//       ),
//       body: Row(
//         children: [
//           Expanded(
//             child: databaseData == null
//                 ? const Center(child: CircularProgressIndicator())
//                 : ListView.separated(
//                     controller: _controller, // 追加
//                     itemCount: databaseData!.length,
//                     separatorBuilder: (context, index) => const Divider(
//                       color: Colors.grey,
//                     ),
//                     itemBuilder: (context, index) {
//                       return ListTile(
//                         title: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(convertToKatakana(
//                                 databaseData![index]['hougen'] ?? '')),
//                             Text(
//                               'ID: ${databaseData![index]['id'].toString()}',
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ],
//                         ),
//                         subtitle: Text(databaseData![index]['japanese'] ?? ''),
//                       );
//                     },
//                   ),
//           ),
          // Column(
          //   children: gojuonList.map((kana) {
          //     return GestureDetector(
          //       onTap: () async {
          //         // print("kana: $kana");
          //         // カタカナからローマ字に変換
          //         String romaji = katakanaToRomaji[kana] ?? kana;
          //         // print("romaji: $romaji"); // デバッグ出力

          //         int targetIndex = databaseData!.indexWhere((element) {
          //           String hougenRomaji = element['hougen'].toString();
          //           String hougenKatakana = convertToKatakana(hougenRomaji);
          //           String firstCharOfElement = hougenKatakana.substring(0, 1);
          //           String firstCharOfKana =
          //               kana.substring(0, 1); // タップされた50音の最初の文字

          //           return firstCharOfElement == firstCharOfKana; // 最初の1文字だけで比較
          //         });

          //         if (targetIndex != -1) {
          //           _controller.jumpTo(_controller.position.minScrollExtent);
          //           await Future.delayed(const Duration(milliseconds: 200));
          //           _controller
          //               .jumpTo(targetIndex * 56.0); // 56.0は1行あたりの高さを指定しています。
          //         } else {
          //           print("Target not found");
          //         }
          //       },
          //       child: SizedBox(
          //         height: 15.0, // 高さを20に設定
          //         child: Text(
          //           kana,
          //           style: const TextStyle(
          //             fontSize: 12.0, // フォントサイズを12に設定
          //           ),
          //         ),
          //       ),
          //     );
          //   }).toList(),
          // ),
        ],
      ),
    );
  } 
}
