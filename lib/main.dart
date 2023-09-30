import 'package:flutter/material.dart';
import 'quiz_page.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF82AAE3)),
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [ // childrenプロパティを追加
              ElevatedButton(
          style: ElevatedButton.styleFrom(
          minimumSize: Size(MediaQuery.of(context).size.width - 0, 50), // 左右一杯
                 ),
                onPressed: () {
                  // quiz_pageに遷移
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const QuizPage()),
                  );
                },
                child: const Text('ボタン'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}