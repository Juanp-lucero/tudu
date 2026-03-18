// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:tudu/main.dart';
import 'package:tudu/src/task_repository.dart';

void main() {
  testWidgets('Home renders today tasks', (WidgetTester tester) async {
    final repo = InMemoryTaskRepository.seeded();

    await tester.pumpWidget(TuduApp(repository: repo, isOffline: true));
    await tester.pumpAndSettle();

    expect(find.text('Today Tasks'), findsOneWidget);
    expect(find.text('Tudu'), findsOneWidget);
  });
}
