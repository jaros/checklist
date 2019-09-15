import 'package:flutter/material.dart';

import 'checklist_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Checklist',
      theme: ThemeData(
        primaryColor: Colors.deepOrangeAccent,
      ),
      home: TodoList(),
    );
  }
}
