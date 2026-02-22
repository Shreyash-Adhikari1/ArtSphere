import 'package:artsphere/features/auth/presentation/pages/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Signup screen loads core UI components', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SignupScreen())),
    );

    await tester.pumpAndSettle();

    expect(find.byType(Form), findsOneWidget);

    // find the fields
    expect(find.byType(TextFormField), findsNWidgets(7));

    // find by labels
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Phone Number'), findsOneWidget);
    expect(find.text('Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);

    //Find the button with text
    expect(find.widgetWithText(ElevatedButton, 'Signup'), findsOneWidget);

    // Find thr rich text and find specific texts
    final alreadyRegisteredFinder = find.byWidgetPredicate((widget) {
      if (widget is! RichText) return false;
      final text = widget.text.toPlainText();
      return text.contains('Already Registered?') && text.contains('Login');
    });

    expect(alreadyRegisteredFinder, findsOneWidget);
  });

  testWidgets('Tapping Signup with empty fields shows validation errors', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SignupScreen())),
    );

    await tester.pumpAndSettle();

    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Signup'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Signup'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter your full name'), findsOneWidget);
    expect(find.text('Please enter your username'), findsOneWidget);
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your phone number'), findsOneWidget);
    expect(find.text('Please enter your address'), findsOneWidget);

    // Both password fields use the same validator message
    expect(find.text('Please enter your password'), findsNWidgets(2));
  });

  testWidgets('Submitting mismatched passwords shows error feedback', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SignupScreen())),
    );

    await tester.pumpAndSettle();

    // Fill all required fields
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Full Name'),
      'Test User',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Username'),
      'testuser',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'test@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Phone Number'),
      '9800000000',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Address'),
      'Kathmandu',
    );

    // Mismatched passwords
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'password123',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Confirm Password'),
      'password456',
    );

    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Signup'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Signup'));
    await tester.pumpAndSettle();

    expect(find.text('Passwords do not match'), findsOneWidget);
  });
}
