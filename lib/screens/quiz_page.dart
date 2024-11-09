import 'package:flutter/material.dart';
import '../utils/db_helper.dart'; // DBHelperクラスをインポート

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
  bool isLoading = true; // ローディング状態を追跡

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
    _searchController.addListener(_filterData); // 検索バーの入力でフィルタリング
  }

  Future<void> _initializeDatabase() async {
    try {
      final db = await DBHelper.db; // データベースの初期化
      await DBHelper.updateDatabaseWithJsonData(); // JSONデータでデータベースを更新

      List<Map<String, dynamic>> fetchedData = await DBHelper.fetchDataFromDatabase(); // データベースからデータ取得

      setState(() {
        databaseData = fetchedData;
        filteredData = databaseData!;
        isLoading = false; // ローディング完了
      });

      print("データベースの初期化とデータ取得が完了しました。取得したデータ件数: ${fetchedData.length}");
    } catch (error) {
      print("Database initialization error: $error");
      setState(() {
        isLoading = false; // エラー時でもローディングを解除
      });
    }
  }

  // データをフィルタリングするメソッド
  void _filterData() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredData = databaseData!.where((item) {
        final hougenText = item['hougen']?.toString().toLowerCase() ?? '';
        return hougenText.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // データがロード中の場合
          : ListView.separated(
              controller: _controller,
              itemCount: filteredData.length,
              separatorBuilder: (context, index) => const Divider(color: Colors.grey),
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    filteredData[index]['hougen'] ?? '',
                    style: const TextStyle(fontSize: 20),
                  ),
                  subtitle: Text(filteredData[index]['japanese'] ?? ''),
                );
              },
            ),
    );
  }
}