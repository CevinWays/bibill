import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bibill/main.dart';

void main() {
  testWidgets('Smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BibillApp());

    // Verify that we start with no subscriptions
    expect(find.text('No subscriptions yet'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
