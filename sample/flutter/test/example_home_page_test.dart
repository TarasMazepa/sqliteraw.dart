import 'dart:io';

import 'package:sample_flutter/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('sqliteraw_flutter_widget_test_');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  testWidgets('ExampleHomePage runs open, CRUD, and backup examples', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: ExampleHomePage(databaseDirectory: tempDir.path)),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('After insert:'), findsOneWidget);
    expect(find.textContaining('After update:'), findsOneWidget);
    expect(find.textContaining('After delete:'), findsOneWidget);
    expect(find.textContaining('Buy milk'), findsWidgets);
    expect(find.textContaining('Backup:'), findsOneWidget);
  });
}
