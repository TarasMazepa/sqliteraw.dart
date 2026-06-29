import 'package:flutter/material.dart';
import 'package:sample_flutter/sample_flutter.dart' as sample;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(body: Center(child: Text('Using sqliteraw_dart version ${sample.version()}!'))),
    );
  }
}
