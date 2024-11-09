import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/word_list_page.dart'; // 単語集
import 'screens/favorites_page.dart';
import 'providers/favorites_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FavoritesProvider(),
      child: MaterialApp(
        title: '沖縄方言単語集',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF82AAE3)),
          scaffoldBackgroundColor: const Color(0xFFBFEAF5),
          useMaterial3: true,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF91D8E4),
              textStyle: const TextStyle(fontSize: 30),
              minimumSize: const Size.fromHeight(100),
            ),
          ),
          textTheme: const TextTheme(
            titleLarge: TextStyle(
              fontSize: 24, // 1行に収まるサイズに調整
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        home: const HomePage(), // ホームページをメイン画面に設定
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // ボトムナビゲーションバーの選択されたタブ

  // ボトムナビゲーションで表示するページを切り替え
  final List<Widget> _pages = [
    const WordListPage(), // 単語集ページ
    const FavoritesPage(),
  ];

  // 選択されたインデックスの更新
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // 選択されたページを表示
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: '単語集', // ラベルを「単語集」に変更
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'お気に入り',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}