import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/db_helper.dart';
import '../providers/favorites_provider.dart';

class WordListPage extends StatefulWidget {
  const WordListPage({Key? key}) : super(key: key);

  @override
  WordListPageState createState() => WordListPageState();
}

class WordListPageState extends State<WordListPage> {
  List<Map<String, dynamic>>? databaseData;
  List<Map<String, dynamic>> filteredData = [];
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
    _searchController.addListener(_filterData);
  }

  Future<void> _initializeDatabase() async {
    try {
      await DBHelper.db;
      await DBHelper.updateDatabaseWithJsonData();
      List<Map<String, dynamic>> fetchedData = await DBHelper.fetchDataFromDatabase();
      setState(() {
        databaseData = fetchedData;
        filteredData = databaseData!;
        isLoading = false;
      });
    } catch (error) {
      print("Database initialization error: $error");
      setState(() {
        isLoading = false;
      });
    }
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('沖縄方言単語集'), // 1行に調整
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
          ? const Center(child: CircularProgressIndicator())
          : Consumer<FavoritesProvider>(
              builder: (context, favoritesProvider, child) {
                return ListView.builder(
                  itemCount: filteredData.length,
                  itemBuilder: (context, index) {
                    final item = filteredData[index];
                    final isFavorite = favoritesProvider.isFavorite(item);
                    return ListTile(
                      title: Text(item['hougen'] ?? ''),
                      subtitle: Text(item['japanese'] ?? ''),
                      trailing: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : null,
                        ),
                        onPressed: () {
                          favoritesProvider.toggleFavorite(item);
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}