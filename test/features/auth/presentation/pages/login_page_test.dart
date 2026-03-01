import 'package:artsphere/features/auth/presentation/pages/login_page.dart';
import 'package:artsphere/features/auth/presentation/state/user_state.dart';
import 'package:artsphere/features/auth/presentation/viewmodels/user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class TestUserViewModel extends UserViewModel {
  TestUserViewModel(this._initial);
  final UserState _initial;

  // captured calls
  int loginCalls = 0;
  String? lastEmail;
  String? lastPassword;

  int biometricCalls = 0;
  bool biometricReturn = false;
  String? biometricErrorToSet;

  @override
  UserState build() {
    return _initial;
  }

  @override
  Future<void> login({required String email, required String password}) async {
    loginCalls++;
    lastEmail = email;
    lastPassword = password;
  }

  @override
  Future<bool> loginWithBiometrics() async {
    biometricCalls++;

    if (biometricErrorToSet != null) {
      state = state.copyWith(
        status: UserStatus.error,
        errorMessage: biometricErrorToSet,
        biometricLoading: false,
      );
    }

    return biometricReturn;
  }
}

Finder textFieldByLabel(String label) {
  final field = find.byType(TextFormField);
  final labelText = find.text(label);
  return find.ancestor(of: labelText, matching: field);
}

void main() {
  testWidgets(
    'Valid inputs -> tapping Login calls viewModel.login() with trimmed email',
    (tester) async {
      final vm = TestUserViewModel(const UserState());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [userViewModelProvider.overrideWith(() => vm)],
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Enter email + password
      await tester.enterText(textFieldByLabel('Email'), '  test@gmail.com  ');
      await tester.enterText(textFieldByLabel('Password'), 'pass123');

      // Tap login
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      // Verify viewmodel call + args
      expect(vm.loginCalls, 1);
      expect(vm.lastEmail, 'test@gmail.com');
      expect(vm.lastPassword, 'pass123');
    },
  );

  testWidgets(
    'Fingerprint button is disabled when biometricAvailable=true but biometricEnabled=false',
    (tester) async {
      final vm = TestUserViewModel(
        const UserState(
          biometricAvailable: true,
          biometricEnabled: false,
          biometricLoading: false,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [userViewModelProvider.overrideWith(() => vm)],
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Button exists (because biometricAvailable == true)
      final bioBtn = find.byType(OutlinedButton);
      expect(bioBtn, findsOneWidget);

      // Disabled because enabled=false
      final btnWidget = tester.widget<OutlinedButton>(bioBtn);
      expect(btnWidget.onPressed, isNull);

      // Label shows the "enable first" text
      expect(find.text('Enable fingerprint login in Profile'), findsOneWidget);
    },
  );

  testWidgets(
    'Biometric login failure -> calls loginWithBiometrics and shows error SnackBar',
    (tester) async {
      final vm =
          TestUserViewModel(
              const UserState(
                biometricAvailable: true,
                biometricEnabled: true,
                biometricLoading: false,
              ),
            )
            ..biometricReturn = false
            ..biometricErrorToSet = 'Fingerprint authentication failed';

      await tester.pumpWidget(
        ProviderScope(
          overrides: [userViewModelProvider.overrideWith(() => vm)],
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Tap fingerprint login
      await tester.tap(find.byType(OutlinedButton));
      await tester.pump(); // allow snackbar enqueue/first frame
      await tester.pump(const Duration(milliseconds: 250)); // animation

      // ViewModel method called
      expect(vm.biometricCalls, 1);

      // SnackBar message visible
      expect(find.text('Fingerprint authentication failed'), findsOneWidget);
    },
  );
}
