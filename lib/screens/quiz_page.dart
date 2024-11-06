import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import '../utils/db_helper.dart'; // db_helper.dart をインポート
import '../utils/romaji_to_katakana.dart'; // romaji_to_katakana.dart をインポート

class QuizPage extends StatefulWidget {
  const QuizPage({Key? key}) : super(key: key);
  @override
  QuizPageState createState() => QuizPageState();
}

class QuizPageState extends State<QuizPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _controller = ScrollController();
  List<Map<String, dynamic>>? databaseData;
  List<Map<String, dynamic>> filteredData = [];
  final Map<String, String> katakanaToRomaji = {};

  @override
  void initState() {
    super.initState();
    initDb().then((_) async {
      List<Map<String, dynamic>> fetchedData = await fetchDataFromDatabase();
      if (fetchedData.isNotEmpty) {
        setState(() {
          databaseData = fetchedData.sublist(1); // 最初の行を削除
          filteredData = databaseData!; // 初期状態で全データを表示
        });
      }
    }).catchError((error) {
      print("initState エラー: $error");
    });

    _searchController.addListener(_filterData);
  }

  void _filterData() {
    final query = convertToKatakana(_searchController.text.toLowerCase()); // カタカナで検索キーワードを変換

    setState(() {
      filteredData = databaseData!.where((item) {
        final hougenTextInKatakana = convertToKatakana(item['hougen']?.toString().toLowerCase() ?? '');
        return hougenTextInKatakana.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String convertToKatakana(String input) {
    StringBuffer output = StringBuffer();
    for (var i = 0; i < input.length; i++) {
      String current = input[i];

      if (i < input.length - 2) {
        String next = input.substring(i, i + 3);
        if (romajiToKatakana.containsKey(next)) {
          output.write(romajiToKatakana[next]);
          i += 2;
          continue;
        }
      }

      if (i < input.length - 1) {
        String next = input.substring(i, i + 2);
        if (romajiToKatakana.containsKey(next)) {
          output.write(romajiToKatakana[next]);
          i++;
          continue;
        }
      }

      if (romajiToKatakana.containsKey(current)) {
        output.write(romajiToKatakana[current]);
      }
    }
    return output.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          '沖縄方言',
          style: TextStyle(fontSize: 40),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: '方言を検索',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      body: databaseData == null
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              controller: _controller,
              itemCount: filteredData.length,
              separatorBuilder: (context, index) => const Divider(color: Colors.grey),
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    convertToKatakana(filteredData[index]['hougen'] ?? ''),
                    style: const TextStyle(fontSize: 20),
                  ),
                  subtitle: Text(filteredData[index]['japanese'] ?? ''),
                );
              },
            ),
    );
  }
}