import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bible_verse/main.dart';

void main() {
  testWidgets('Bible Verse app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BibleVerseApp());

    // Verify that the app title is displayed
    expect(find.text('Bible Verse'), findsOneWidget);
    
    // Verify that the microphone button is present
    expect(find.byIcon(Icons.mic_none), findsOneWidget);
    
    // Verify that the instruction text is displayed
    expect(find.text('Say a Bible verse reference to see it displayed'), findsOneWidget);
  });
}