//最低限のページ
import 'package:flutter/material.dart';


// //QuiZPageクラスを定義
// class QuizPage extends StatefulWidget {
//   const QuizPage({Key? key}) : super(key: key);
//
//   @override
//   State<QuizPage> createState() => _QuizPageState();
// }

class QuizPage extends StatelessWidget {
  const QuizPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Quiz Page'),
      ),
    );
  }
}