import 'package:artsphere/core/themes/theme_notifier.dart';
import 'package:artsphere/features/auth/domain/entities/user_entity.dart';
import 'package:artsphere/features/auth/presentation/pages/profile_page.dart';
import 'package:artsphere/features/auth/presentation/state/user_state.dart';
import 'package:artsphere/features/auth/presentation/viewmodels/user_view_model.dart';
import 'package:artsphere/features/post/presentation/states/post_state.dart';
import 'package:artsphere/features/post/presentation/viewmodels/post_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class TestThemeModeNotifier extends ThemeModeNotifier {
  final ThemeMode _mode;
  TestThemeModeNotifier(this._mode);

  @override
  ThemeMode build() => _mode;
}

class TestUserViewModel extends UserViewModel {
  TestUserViewModel(this._initial);
  final UserState _initial;

  @override
  UserState build() => _initial;

  @override
  Future<void> getProfile() async {}
}

class TestPostViewModel extends PostViewModel {
  TestPostViewModel(this._initial);
  final PostState _initial;

  @override
  PostState build() => _initial;

  @override
  Future<void> loadMyPosts() async {}
}

void main() {
  testWidgets('Shows loading spinner when userState.status == loading', (
    tester,
  ) async {
    final userVm = TestUserViewModel(
      const UserState(status: UserStatus.loading),
    );
    final postVm = TestPostViewModel(const PostState());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          themeModeProvider.overrideWith(
            () => TestThemeModeNotifier(ThemeMode.light),
          ),
          userViewModelProvider.overrideWith(() => userVm),
          postViewModelProvider.overrideWith(() => postVm),
        ],
        child: const MaterialApp(home: ProfilePage()),
      ),
    );

    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Shows "No user data" when userEntity is null and not loading', (
    tester,
  ) async {
    final userVm = TestUserViewModel(
      const UserState(status: UserStatus.initial, userEntity: null),
    );
    final postVm = TestPostViewModel(const PostState());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          themeModeProvider.overrideWith(
            () => TestThemeModeNotifier(ThemeMode.light),
          ),
          userViewModelProvider.overrideWith(() => userVm),
          postViewModelProvider.overrideWith(() => postVm),
        ],
        child: const MaterialApp(home: ProfilePage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text("No user data"), findsOneWidget);
  });

  testWidgets('Displays user information when userEntity exists', (
    tester,
  ) async {
    const user = UserEntity(
      userId: "u1",
      fullName: "John Doe",
      username: "johndoe",
      email: "john@example.com",
      password: null,
      confirmPassword: null,
      followerCount: 5,
      followingCount: 10,
      postCount: 3,
      bio: "Flutter Developer",
    );

    final userVm = TestUserViewModel(
      const UserState(status: UserStatus.authenticated, userEntity: user),
    );
    final postVm = TestPostViewModel(const PostState());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          themeModeProvider.overrideWith(
            () => TestThemeModeNotifier(ThemeMode.light),
          ),
          userViewModelProvider.overrideWith(() => userVm),
          postViewModelProvider.overrideWith(() => postVm),
        ],
        child: const MaterialApp(home: ProfilePage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text("@johndoe"), findsOneWidget);
    expect(find.text("John Doe"), findsOneWidget);
    expect(find.text("Flutter Developer"), findsOneWidget);

    expect(find.text("3"), findsOneWidget);
    expect(find.text("5"), findsOneWidget);
    expect(find.text("10"), findsOneWidget);

    expect(find.text("Edit Profile"), findsOneWidget);
  });
}
