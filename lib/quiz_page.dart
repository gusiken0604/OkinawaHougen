import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';

Database? db; // データベースを保持するためのグローバル変数

Future<void> initDb() async {
  try {
    var databasesPath = await getDatabasesPath();
    var path =
        join(databasesPath, "okinawahougen.db"); //assets/okinawahougen.db"

    var exists = await databaseExists(path);

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
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  ScrollController _controller = ScrollController();  // 追加
  List<Map<String, dynamic>>? databaseData;

  // カタカナからローマ字に変換する辞書を作成
  final Map<String, String> katakanaToRomaji = {};

  // 50音順のリスト
  List<String> gojuonList = [
    'ア',
    'イ',
    'ウ',
    'エ',
    'オ',
    'カ',
    'キ',
    'ク',
    'ケ',
    'コ',
    'サ',
    'シ',
    'ス',
    'セ',
    'ソ',
    'タ',
    'チ',
    'ツ',
    'テ',
    'ト',
    'ナ',
    'ニ',
    'ヌ',
    'ネ',
    'ノ',
    'ハ',
    'ヒ',
    'フ',
    'ヘ',
    'ホ',
    'マ',
    'ミ',
    'ム',
    'メ',
    'モ',
    'ヤ',
    'ユ',
    'ヨ',
    'ラ',
    'リ',
    'ル',
    'レ',
    'ロ',
    'ワ',
    'ヲ',
    'ン',
  ];
  String selectedKana = ''; //選択されている50音の文字を保持
  // ローマ字からカタカナへのマッピング
  final Map<String, String> romajiToKatakana = {
    // ここに対応表を挿入
    "?a": "ア",
    "a": "ア",
    "?i": "イ",
    "i": "イ",
    "?u": "ウ",
    "u": "ウ",
    "?e": "エ",
    "e": "エ",
    "?o": "オ",
    "o": "オ",
    "’a": "ア",
    "'a": "ア",
    "’i": "イ",
    "'i": "イ",
    "ji": "イ",
    "’u": "ウ",
    "'u": "ウ",
    "wu": "ウ",
    "’e": "エ",
    "'e": "エ",
    "’o": "オ",
    "'o": "オ",
    "ka": "カ",
    "ki": "キ",
    "ku": "ク",
    "ke": "ケ",
    "ko": "コ",
    "kja": "キャ",
    "kju": "キュ",
    "kjo": "キョ",
    "kwa": "クヮ",
    "kwi": "クィ",
    "kwe": "クェ",
    "ga": "ガ",
    "gi": "ギ",
    "gu": "グ",
    "ge": "ゲ",
    "go": "ゴ",
    "gja": "ギャ",
    "gju": "ギュ",
    "gjo": "ギョ",
    "gwa": "グヮ",
    "gwi": "グィ",
    "gwe": "グェ",
    "sa": "サ",
    "si": "スィ",
    "su": "ス",
    "se": "セ",
    "so": "ソ",
    "Sa": "シャ",
    "Si": "シ",
    "Su": "シュ",
    "Se": "シェ",
    "So": "ショ",
    "Za": "ザ",
    "Zi": "ズィ",
    "Zu": "ズ",
    "Ze": "ゼ",
    "Zo": "ゾ",
    "za": "ジャ",
    "zi": "ジ",
    "zu": "ジュ",
    "ze": "ジェ",
    "zo": "ジョ",
    "ta": "タ",
    "ti": "ティ",
    "tu": "トゥ",
    "te": "テ",
    "to": "ト",
    "da": "ダ",
    "di": "ディ",
    "du": "ドゥ",
    "de": "デ",
    "do": "ド",
    "Ca": "ツァ",
    "tsa": "ツァ",
    "Ci": "ツィ",
    "tsi": "ツィ",
    "Cu": "ツ",
    "tsu": "ツ",
    "Ce": "ツェ",
    "tse": "ツェ",
    "Co": "ツォ",
    "tso": "ツォ",
    "ca": "チャ",
    "ci": "チ",
    "cu": "チュ",
    "ce": "チェ",
    "co": "チョ",
    "na": "ナ",
    "ni": "ニ",
    "nji": "ニ",
    "nu": "ヌ",
    "ne": "ネ",
    "no": "ノ",
    "nja": "ニャ",
    "nju": "ニュ",
    "nje": "ニェ",
    "njo": "ニョ",
    "ha": "ハ",
    "he": "ヘ",
    "ho": "ホ",
    "hja": "ヒャ",
    "hi": "ヒ",
    "hji": "ヒ",
    "hju": "ヒュ",
    "hjo": "ヒョ",
    "hwa": "ファ",
    "hwi": "フィ",
    "hu": "フ",
    "hwu": "フ",
    "hwe": "フェ",
    "hwo": "フォ",
    "pa": "パ",
    "pi": "ピ",
    "pu": "プ",
    "pe": "ぺ",
    "po": "ポ",
    "pja": "ピャ",
    "pju": "ピュ",
    "pjo": "ピョ",
    "ba": "バ",
    "bi": "ビ",
    "bu": "ブ",
    "be": "ベ",
    "bo": "ボ",
    "bja": "ビャ",
    "bju": "ビュ",
    "bjo": "ビョ",
    "ma": "マ",
    "mi": "ミ",
    "mu": "ム",
    "me": "メ",
    "mo": "モ",
    "mja": "ミャ",
    "mju": "ミュ",
    "mjo": "ミョ",
    "ja": "ヤ",
    "ju": "ユ",
    "je": "イェ",
    "jo": "ヨ",
    "?ja": "?ヤ",
    "?ju": "?ユ",
    "?je": "?イェ",
    "?jo": "?ヨ",
    "ra": "ラ",
    "ri": "リ",
    "ru": "ル",
    "re": "レ",
    "ro": "ロ",
    "rja": "リャ",
    "rju": "リュ",
    "rjo": "リョ",
    "wa": "ワ",
    "wi": "ウィ",
    "we": "ウェ",
    "wo": "ウォ",
    "?wa": "?ワ",
    "?wi": "?ウィ",
    "?we": "?ウェ",
    "Q": "ッ",
    "N": "ン",
    "sja": "シャ",
    "sji": "シ",
    "sju": "シュ",
    "sje": "シェ",
    "sjo": "ショ",
    "'ja": "ヤ",
    "'ju": "ユ",
    "'je": "イェ",
    "'jo": "ヨ",
    "bwi": "ブィ",
    "?ma": "ッマ",
    "?mi": "ッミ",
    "?mu": "ッム",
    "?me": "ッメ",
    "?mo": "ッモ",
    "?n": "ッン",
    "?N": "ッン",
    "'wa": "ワ",
    "'wi": "ウィ",
    "'wu": "ウ",
    "'we": "ウェ",
    "'wo": "ウォ"
  };

  String convertToKatakana(String input) {
    StringBuffer output = StringBuffer();
    for (var i = 0; i < input.length; i++) {
      String current = input[i];

      if (i < input.length - 1) {
        String next = input[i + 1];
        String combined = "$current$next";

        if (romajiToKatakana.containsKey(combined)) {
          output.write(romajiToKatakana[combined]);
          i++; // 2文字分処理したのでインデックスを1つ進める
          continue;
        }
      }

      output.write(romajiToKatakana[current] ?? current);
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
    print("katakanaToRomaji: $katakanaToRomaji");


    initDb().then((_) async {
      List<Map<String, dynamic>> fetchedData = await fetchDataFromDatabase();
      setState(() {
        databaseData = fetchedData;
      });
    }).catchError((error) {
      print("initState エラー: $error");
    });

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
      body: Row(
        children: [
          Expanded(
            child: databaseData == null
                ? Center(child: CircularProgressIndicator())
                : ListView.separated(
              controller: _controller, // 追加
              itemCount: databaseData!.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey,
              ),
              itemBuilder: (context, index) {
                return ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(convertToKatakana(
                          databaseData![index]['hougen'] ?? '')),
                      Text(
                        'ID: ${databaseData![index]['id'].toString()}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(databaseData![index]['japanese'] ?? ''),
                );
              },
            ),
          ),
          Column(
            children: gojuonList.map((kana) {
              return GestureDetector(
                onTap: () async {
                  print("kana: $kana");
                  // カタカナからローマ字に変換
                  String romaji = katakanaToRomaji[kana] ?? kana;
                  print("romaji: $romaji"); // デバッグ出力

                  int targetIndex = databaseData!.indexWhere((element) {
                    String hougenRomaji = element['hougen'].toString();
                    String hougenKatakana = convertToKatakana(hougenRomaji);
                    String firstCharOfElement = hougenKatakana.substring(0, 1);
                    String firstCharOfKana = kana.substring(0, 1); // タップされた50音の最初の文字

                    return firstCharOfElement == firstCharOfKana; // 最初の1文字だけで比較
                  });

                  if (targetIndex != -1) {
                    _controller.jumpTo(_controller.position.minScrollExtent);
                    await Future.delayed(Duration(milliseconds: 200));
                    _controller.jumpTo(targetIndex * 56.0); // 56.0は1行あたりの高さを指定しています。
                  } else {
                    print("Target not found");
                  }

                },
                child: Container(
                  height: 15.0,  // 高さを20に設定
                  child: Text(
                    kana,
                    style: TextStyle(
                      fontSize: 12.0,  // フォントサイズを12に設定
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}