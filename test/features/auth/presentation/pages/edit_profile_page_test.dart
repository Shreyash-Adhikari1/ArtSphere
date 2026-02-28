import 'package:artsphere/features/auth/presentation/pages/edit_profile_page.dart';
import 'package:artsphere/features/auth/presentation/state/user_state.dart';
import 'package:artsphere/features/auth/presentation/viewmodels/user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeUserViewModel extends UserViewModel {
  final UserState _state;

  FakeUserViewModel(this._state);

  @override
  UserState build() => _state;
}

class _MutableFakeUserViewModel extends UserViewModel {
  UserState _state;
  _MutableFakeUserViewModel(this._state);

  @override
  UserState build() => _state;

  void emit(UserState next) {
    _state = next;
    state = next;
  }
}

Future<void> pumpPage(WidgetTester tester, {required UserState state}) async {
  final vm = FakeUserViewModel(state);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [userViewModelProvider.overrideWith(() => vm)],
      child: const MaterialApp(home: EditProfilePage()),
    ),
  );

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  group('EditProfilePage Widget Tests', () {
    testWidgets('1) Loads core UI components', (tester) async {
      await pumpPage(
        tester,
        state: const UserState(
          status: UserStatus.initial,
          biometricAvailable: false,
          biometricEnabled: false,
        ),
      );

      // AppBar back button exists
      expect(find.byType(BackButton), findsOneWidget);

      // Avatar exists (CircleAvatar)
      expect(find.byType(CircleAvatar), findsOneWidget);

      // Input fields (TextField) - Full name, Username, Phone, Address
      expect(find.byType(TextField), findsNWidgets(4));

      // Save button should be visible when NOT loading
      expect(find.widgetWithText(ElevatedButton, 'Save'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets(
      '2) When state.status == loading, shows CircularProgressIndicator and hides Save button',
      (tester) async {
        await pumpPage(
          tester,
          state: const UserState(
            status: UserStatus.loading,
            biometricAvailable: false,
            biometricEnabled: false,
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.widgetWithText(ElevatedButton, 'Save'), findsNothing);
      },
    );

    testWidgets('3) When status changes to error, shows SnackBar', (
      tester,
    ) async {
      final vm = _MutableFakeUserViewModel(
        const UserState(
          status: UserStatus.initial,
          biometricAvailable: false,
          biometricEnabled: false,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [userViewModelProvider.overrideWith(() => vm)],
          child: const MaterialApp(home: EditProfilePage()),
        ),
      );

      // Let initial build + listener setup happen
      await tester.pump();

      vm.emit(
        const UserState(
          status: UserStatus.error,
          errorMessage: 'Something went wrong',
          biometricAvailable: false,
          biometricEnabled: false,
        ),
      );

      // Pump to allow listener + snackbar animation
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
    });
  });
}
