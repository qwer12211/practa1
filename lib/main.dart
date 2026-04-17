import 'package:flutter/material.dart';
import 'widgets/joke_list.dart';

void main() {
  runApp(const JokeApp());
}

class JokeApp extends StatelessWidget {
  const JokeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dad Jokes',
      home: Scaffold(
        appBar: AppBar(title: const Text('Шутки от бати')),
        body: const SafeArea(child: JokeList()),
      ),
    );
  }
}
