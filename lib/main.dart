import 'package:flutter/material.dart';
import 'screens/quiz_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  //var baa = 3AB79AFF
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '沖縄方言',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF82AAE3)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '沖縄方言'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

   final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBFEAF5), // ここで背景色を指定
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 40,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // childrenプロパティを追加
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  //ボタンの色を変える
                  backgroundColor: const Color(0xFF91D8E4),
                  minimumSize:
                      Size(MediaQuery.of(context).size.width - 0, 100), // 左右一杯
                ),
                onPressed: () {
                  // quiz_pageに遷移
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const QuizPage()),
                  );
                },
                child: const Text('沖縄方言→日本語',
                  style: TextStyle(
                    //色を変える//91D8E4

                    //color: Color(91D8E4),
                    fontSize: 30,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}