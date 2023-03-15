import 'package:flutter/material.dart';
import 'package:toilenow/search_toilet_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'トイレなう',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SearchToiletPage(),
    );
  }
}
