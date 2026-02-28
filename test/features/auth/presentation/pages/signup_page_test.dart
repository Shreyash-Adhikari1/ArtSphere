import 'package:artsphere/features/auth/presentation/pages/login_page.dart';
import 'package:artsphere/features/auth/presentation/pages/signup_page.dart';
import 'package:artsphere/features/auth/presentation/state/user_state.dart';
import 'package:artsphere/features/auth/presentation/viewmodels/user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class TestUserViewModel extends UserViewModel {
  TestUserViewModel(this._initial);
  final UserState _initial;

  int registerCalls = 0;

  // captured params
  String? fullName;
  String? username;
  String? email;
  String? password;
  String? confirmPassword;
  String? address;
  String? phoneNumber;

  @override
  UserState build() => _initial;

  @override
  Future<void> register({
    required String fullName,
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    String? address,
    String? phoneNumber,
  }) async {
    registerCalls++;

    this.fullName = fullName;
    this.username = username;
    this.email = email;
    this.password = password;
    this.confirmPassword = confirmPassword;
    this.address = address;
    this.phoneNumber = phoneNumber;
  }

  void emit(UserState next) {
    state = next;
  }
}

// Finds the TextFormField that contains a given label text in its subtree
Finder textFieldByLabel(String label) {
  final labelFinder = find.text(label);
  return find.ancestor(of: labelFinder, matching: find.byType(TextFormField));
}

Future<void> fillValidForm(
  WidgetTester tester, {
  String? confirmPassword,
}) async {
  await tester.enterText(textFieldByLabel('Full Name'), 'Test User');
  await tester.enterText(textFieldByLabel('Username'), 'testuser');
  await tester.enterText(textFieldByLabel('Email'), 'test@example.com');
  await tester.enterText(textFieldByLabel('Phone Number'), '9800000000');
  await tester.enterText(textFieldByLabel('Address'), 'Kathmandu');
  await tester.enterText(textFieldByLabel('Password'), 'password123');
  await tester.enterText(
    textFieldByLabel('Confirm Password'),
    confirmPassword ?? 'password123',
  );
}

void main() {
  testWidgets(
    'Valid form -> tapping Signup calls viewModel.register with correct values',
    (tester) async {
      final vm = TestUserViewModel(const UserState());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [userViewModelProvider.overrideWith(() => vm)],
          child: const MaterialApp(home: SignupScreen()),
        ),
      );

      await tester.pumpAndSettle();

      await fillValidForm(tester);

      await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Signup'));
      await tester.tap(find.widgetWithText(ElevatedButton, 'Signup'));
      await tester.pumpAndSettle();

      expect(vm.registerCalls, 1);
      expect(vm.fullName, 'Test User');
      expect(vm.username, 'testuser');
      expect(vm.email, 'test@example.com');
      expect(vm.phoneNumber, '9800000000');
      expect(vm.address, 'Kathmandu');
      expect(vm.password, 'password123');
      expect(vm.confirmPassword, 'password123');
    },
  );

  testWidgets(
    'Mismatched passwords -> shows SnackBar and does NOT call register',
    (tester) async {
      final vm = TestUserViewModel(const UserState());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [userViewModelProvider.overrideWith(() => vm)],
          child: const MaterialApp(home: SignupScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Fill required fields (valid except passwords mismatch)
      await fillValidForm(tester, confirmPassword: 'different456');

      final signupBtn = find.widgetWithText(ElevatedButton, 'Signup');

      await tester.ensureVisible(signupBtn);
      await tester.pumpAndSettle();

      // Tap
      await tester.tap(signupBtn);
      await tester.pump(); // let SnackBar enqueue

      // SnackBar appears
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Passwords do not match'), findsOneWidget);

      // Register should NOT be called
      expect(vm.registerCalls, 0);
    },
  );

  testWidgets(
    'When ViewModel emits registered -> shows success snackbar and navigates to LoginScreen',
    (tester) async {
      final vm = TestUserViewModel(const UserState());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [userViewModelProvider.overrideWith(() => vm)],
          child: const MaterialApp(home: SignupScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Emit state that triggers the ref.listen in SignupScreen
      vm.emit(const UserState(status: UserStatus.registered));

      await tester.pump();
      await tester.pump(
        const Duration(milliseconds: 300),
      ); // snack + nav animations

      // Snackbar text from your code:
      expect(
        find.text('Registration successful! Please login.'),
        findsOneWidget,
      );

      // Navigation should remove until LoginScreen
      expect(find.byType(LoginScreen), findsOneWidget);
    },
  );

  testWidgets('When ViewModel emits error -> shows error snackbar message', (
    tester,
  ) async {
    final vm = TestUserViewModel(const UserState());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [userViewModelProvider.overrideWith(() => vm)],
        child: const MaterialApp(home: SignupScreen()),
      ),
    );

    await tester.pumpAndSettle();

    vm.emit(
      const UserState(
        status: UserStatus.error,
        errorMessage: 'Email already exists',
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Email already exists'), findsOneWidget);
  });
}
