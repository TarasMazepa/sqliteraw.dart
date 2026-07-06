import 'package:flutter/material.dart';
import 'package:sample_flutter/example/create_and_crud.dart';
import 'package:sample_flutter/models/example_results.dart' as sample;
import 'package:sample_flutter/sample_flutter.dart' as sample;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, this.databaseDirectory});

  /// When set, database files are stored in this directory instead of the
  /// platform application documents directory.
  final String? databaseDirectory;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: ExampleHomePage(databaseDirectory: databaseDirectory));
  }
}

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key, this.databaseDirectory});

  final String? databaseDirectory;

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  String _status = 'Running sqliteraw examples...';

  @override
  void initState() {
    super.initState();
    _runExamples();
  }

  Future<void> _runExamples() async {
    try {
      final sample.FlutterExampleResults results = await sample.runAllExamples(directoryPath: widget.databaseDirectory);

      if (!mounted) {
        return;
      }

      final String crudSummary =
          'After insert:\n${formatTodoList(results.crudResult.afterInsert)}\n\n'
          'After update:\n${formatTodoList(results.crudResult.afterUpdate)}\n\n'
          'After delete:\n${formatTodoList(results.crudResult.afterDelete)}';

      setState(() {
        _status =
            'sqliteraw ${sample.version()}\n\n'
            'Open: ${results.openDatabasePath}\n\n'
            'CRUD:\n$crudSummary\n\n'
            'Backup: ${results.backupDatabasePath}';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _status = 'Error: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('sqliteraw sample')),
      body: Padding(padding: const EdgeInsets.all(16), child: Text(_status)),
    );
  }
}
