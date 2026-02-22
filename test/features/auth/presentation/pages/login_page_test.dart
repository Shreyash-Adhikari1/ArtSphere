import 'package:artsphere/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Login screen loads core UI components', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginScreen())),
    );

    // Why: allows async build/layout work to finish so finders become reliable.
    await tester.pumpAndSettle();

    // Form exists
    expect(find.byType(Form), findsOneWidget);

    // Two fields: Email + Password
    expect(find.byType(TextFormField), findsNWidgets(2));

    // Labels (unique in your UI)
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    // Button specifically (avoids the "Login appears twice" problem)
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);

    // Other visible text
    expect(find.text('Forgot Your Password ?'), findsOneWidget);
  });

  testWidgets('Tapping Login with empty fields shows validation errors', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginScreen())),
    );

    await tester.pumpAndSettle();

    // Tap the Login button without entering anything
    await tester.ensureVisible(
      find.widgetWithText(ElevatedButton, 'Login'),
    ); // scrolls until visible
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    // Validator messages should appear
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
  });
}
