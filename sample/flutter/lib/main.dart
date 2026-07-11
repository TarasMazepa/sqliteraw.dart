import 'package:flutter/material.dart';
import 'package:sqliteraw_sample_dart/open_database_example.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('sqliteraw open database')),
        body: FutureBuilder<List<String>>(
          future: runOpenDatabaseExample(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Padding(padding: const EdgeInsets.all(16), child: Text('sqliteraw error: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return const Center(child: Text('Running open database example...'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SelectableText(snapshot.data!.join()),
            );
          },
        ),
      ),
    );
  }
}
