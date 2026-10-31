import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/data/project_store.dart';
import 'package:orbit/main.dart';

void main() {
  testWidgets('Home opens the Tasks screen and Back returns to Home',
      (WidgetTester tester) async {
    await tester.pumpWidget(OrbitApp(store: ProjectStore()));

    expect(find.text('Q4 MARKETING LAUNCH'), findsOneWidget);

    // Navigator.push: Home -> Tasks
    await tester.tap(find.text('Tasks'));
    await tester.pumpAndSettle();
    expect(find.text('My tasks'), findsOneWidget);

    // Navigator.pop: Tasks -> Home
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Q4 MARKETING LAUNCH'), findsOneWidget);
  });

  testWidgets('Adding an empty task shows a SnackBar message',
      (WidgetTester tester) async {
    await tester.pumpWidget(OrbitApp(store: ProjectStore()));

    await tester.tap(find.text('Tasks'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add a task'));
    await tester.pumpAndSettle();

    // The text field is empty, so tapping the add button must complain.
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pump();

    expect(find.text('Please type a task name first.'), findsOneWidget);
  });

  testWidgets('Typing a task name adds it to the store',
      (WidgetTester tester) async {
    final store = ProjectStore();
    await tester.pumpWidget(OrbitApp(store: store));

    await tester.tap(find.text('Tasks'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add a task'));
    await tester.pumpAndSettle();

    final before = store.tasks.length;
    await tester.enterText(find.byType(TextField), 'Write report');
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pump();

    expect(store.tasks.length, before + 1);
    expect(find.text('Task added to Today'), findsOneWidget);
  });

  testWidgets('Sending a chat message adds it to the conversation',
      (WidgetTester tester) async {
    final store = ProjectStore();
    await tester.pumpWidget(OrbitApp(store: store));

    await tester.tap(find.text('Chats'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, 'See you at noon');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pump();

    expect(find.text('See you at noon'), findsOneWidget);
  });
}
