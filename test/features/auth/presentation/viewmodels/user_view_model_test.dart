import 'package:artsphere/core/services/biometrics/biometric_service.dart';
import 'package:artsphere/core/services/storage/biometric_pref_service.dart';
import 'package:artsphere/core/services/storage/token_service.dart';
import 'package:artsphere/core/services/storage/user_session_service.dart';
import 'package:artsphere/features/auth/domain/entities/user_entity.dart';
import 'package:artsphere/features/auth/domain/usecases/edit_profile_usecase.dart';
import 'package:artsphere/features/auth/domain/usecases/get_profile_usecase.dart';
import 'package:artsphere/features/auth/domain/usecases/get_users_profile_usecase.dart';
import 'package:artsphere/features/auth/domain/usecases/login_usecase.dart';
import 'package:artsphere/features/auth/domain/usecases/logout_usecase.dart';
import 'package:artsphere/features/auth/domain/usecases/register_usecase.dart';
import 'package:artsphere/features/auth/domain/usecases/request_password_reset_usecase.dart';
import 'package:artsphere/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:artsphere/features/auth/presentation/state/user_state.dart';
import 'package:artsphere/features/auth/presentation/viewmodels/user_view_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// =======================
// Mocks
// =======================
class MockRegisterUsecase extends Mock implements RegisterUsecase {}

class MockLoginUsecase extends Mock implements LoginUsecase {}

class MockGetProfileUsecase extends Mock implements GetProfileUsecase {}

class MockEditProfileUsecase extends Mock implements EditProfileUsecase {}

class MockLogoutUsecase extends Mock implements LogoutUsecase {}

class MockGetUsersProfileUsecase extends Mock
    implements GetUsersProfileUsecase {}

class MockRequestPasswordResetUsecase extends Mock
    implements RequestPasswordResetUsecase {}

class MockResetPasswordUsecase extends Mock implements ResetPasswordUsecase {}

class MockBiometricService extends Mock implements BiometricService {}

class MockBiometricPrefService extends Mock implements BiometricPrefService {}

class MockTokenService extends Mock implements TokenService {}

class MockUserSessionService extends Mock implements UserSessionService {}

class MockUserEntity extends Mock implements UserEntity {}

// =======================
// Fakes (for any())
// =======================
class FakeLoginParams extends Fake implements LoginUsecaseParams {}

class FakeRegisterParams extends Fake implements RegisterUsecaseParams {}

class FakeEditProfileParams extends Fake implements EditProfileUsecaseParams {}

class FakeLogoutParams extends Fake implements LogoutParams {}

class FakeGetUsersProfileParams extends Fake
    implements GetUsersProfileUsecaseParams {}

class FakeRequestResetParams extends Fake
    implements RequestPasswordResetParams {}

class FakeResetPasswordParams extends Fake implements ResetPasswordParams {}

class FakeUserEntity extends Fake implements UserEntity {}

void main() {
  late MockRegisterUsecase mockRegister;
  late MockLoginUsecase mockLogin;
  late MockGetProfileUsecase mockGetProfile;
  late MockEditProfileUsecase mockEditProfile;
  late MockLogoutUsecase mockLogout;
  late MockGetUsersProfileUsecase mockGetUsersProfile;
  late MockRequestPasswordResetUsecase mockRequestReset;
  late MockResetPasswordUsecase mockResetPassword;

  late MockBiometricService mockBiometricService;
  late MockBiometricPrefService mockBiometricPref;
  late MockTokenService mockTokenService;
  late MockUserSessionService mockUserSession;

  ProviderContainer makeContainer() {
    return ProviderContainer(
      overrides: [
        registerUsecaseProvider.overrideWithValue(mockRegister),
        loginUsecaseProvider.overrideWithValue(mockLogin),
        getProfileUsecaseProvider.overrideWithValue(mockGetProfile),
        editProfileUsecaseProvider.overrideWithValue(mockEditProfile),
        logoutUsecaseProvider.overrideWithValue(mockLogout),
        getUsersProfileUsecaseProvider.overrideWithValue(mockGetUsersProfile),
        requestPasswordResetUsecaseProvider.overrideWithValue(mockRequestReset),
        resetPasswordUsecaseProvider.overrideWithValue(mockResetPassword),
        biometricServiceProvider.overrideWithValue(mockBiometricService),
        biometricPrefServiceProvider.overrideWithValue(mockBiometricPref),
        tokenServiceProvider.overrideWithValue(mockTokenService),
        userSessionServiceProvider.overrideWithValue(mockUserSession),
      ],
    );
  }

  Future<void> flushMicrotasks() async {
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
  }

  setUpAll(() {
    registerFallbackValue(FakeLoginParams());
    registerFallbackValue(FakeRegisterParams());
    registerFallbackValue(FakeEditProfileParams());
    registerFallbackValue(FakeLogoutParams());
    registerFallbackValue(FakeGetUsersProfileParams());
    registerFallbackValue(FakeRequestResetParams());
    registerFallbackValue(FakeResetPasswordParams());
  });

  setUp(() {
    mockRegister = MockRegisterUsecase();
    mockLogin = MockLoginUsecase();
    mockGetProfile = MockGetProfileUsecase();
    mockEditProfile = MockEditProfileUsecase();
    mockLogout = MockLogoutUsecase();
    mockGetUsersProfile = MockGetUsersProfileUsecase();
    mockRequestReset = MockRequestPasswordResetUsecase();
    mockResetPassword = MockResetPasswordUsecase();

    mockBiometricService = MockBiometricService();
    mockBiometricPref = MockBiometricPrefService();
    mockTokenService = MockTokenService();
    mockUserSession = MockUserSessionService();

    when(() => mockBiometricService.canCheck()).thenAnswer((_) async => true);
    when(() => mockBiometricPref.isEnabled()).thenReturn(false);

    when(() => mockGetProfile()).thenAnswer(
      (_) async => Right(
        UserEntity(
          userId: "base",
          fullName: "Base",
          username: "baseuser",
          email: "base@gmail.com",
          password: "",
          confirmPassword: "",
        ),
      ),
    );

    // safe defaults for other usecases
    when(
      () => mockRegister.call(any()),
    ).thenAnswer((_) async => const Right(false));
    when(
      () => mockLogin.call(any()),
    ).thenAnswer((_) async => Right(FakeUserEntity()));
    when(
      () => mockEditProfile.call(any()),
    ).thenAnswer((_) async => const Right(false));
    when(
      () => mockLogout.call(any()),
    ).thenAnswer((_) async => const Right(true));
    when(
      () => mockGetUsersProfile.call(any()),
    ).thenAnswer((_) async => Right(FakeUserEntity()));
    when(
      () => mockRequestReset.call(any()),
    ).thenAnswer((_) async => const Right("Reset link sent"));
    when(
      () => mockResetPassword.call(any()),
    ).thenAnswer((_) async => const Right(true));

    when(
      () => mockBiometricService.authenticate(),
    ).thenAnswer((_) async => true);
    when(() => mockBiometricPref.setEnabled(any())).thenAnswer((_) async {});
    when(() => mockTokenService.getToken()).thenAnswer((_) async => "token123");

    when(
      () => mockUserSession.saveUserSession(
        userId: any(named: "userId"),
        email: any(named: "email"),
        fullName: any(named: "fullName"),
        username: any(named: "username"),
        phoneNumber: any(named: "phoneNumber"),
        address: any(named: "address"),
        profilePicture: any(named: "profilePicture"),
      ),
    ).thenAnswer((_) async {});
  });

  // =========================================================
  // TEST 1: build() initializes biometrics flags
  // =========================================================
  test(
    'build() -> sets biometricAvailable and biometricEnabled correctly',
    () async {
      when(() => mockBiometricService.canCheck()).thenAnswer((_) async => true);
      when(() => mockBiometricPref.isEnabled()).thenReturn(true);

      final container = makeContainer();
      addTearDown(container.dispose);

      container.read(userViewModelProvider.notifier);
      await flushMicrotasks();

      final state = container.read(userViewModelProvider);
      expect(state.biometricAvailable, true);
      expect(state.biometricEnabled, true);

      verify(() => mockBiometricService.canCheck()).called(1);
      verify(() => mockBiometricPref.isEnabled()).called(1);
    },
  );

  // =========================================================
  // TEST 2: setBiometricEnabled(true) blocked when biometrics not available
  // =========================================================
  test(
    'setBiometricEnabled(true) when not available -> sets error and does not authenticate/save',
    () async {
      when(
        () => mockBiometricService.canCheck(),
      ).thenAnswer((_) async => false);
      when(() => mockBiometricPref.isEnabled()).thenReturn(false);

      final container = makeContainer();
      addTearDown(container.dispose);

      container.read(userViewModelProvider.notifier);
      await flushMicrotasks();

      await container
          .read(userViewModelProvider.notifier)
          .setBiometricEnabled(true);

      final state = container.read(userViewModelProvider);
      expect(state.status, UserStatus.error);
      expect(state.errorMessage, "Biometrics not available on this device");

      verifyNever(() => mockBiometricService.authenticate());
      verifyNever(() => mockBiometricPref.setEnabled(true));
    },
  );

  // =========================================================
  // TEST 3: loginWithBiometrics() success path
  // =========================================================
  test(
    'loginWithBiometrics success -> saves session, sets authenticated, returns true',
    () async {
      // Make biometrics available + enabled
      when(() => mockBiometricService.canCheck()).thenAnswer((_) async => true);
      when(() => mockBiometricPref.isEnabled()).thenReturn(true);

      // Token exists
      when(
        () => mockTokenService.getToken(),
      ).thenAnswer((_) async => "token123");

      // IMPORTANT: use a Mock (not Fake) and stub getters used in loginWithBiometrics()
      final profile = UserEntity(
        userId: "u-1",
        fullName: "Test User",
        username: "testuser",
        email: "test@gmail.com",
        password: "",
        confirmPassword: "",
        phoneNumber: "9800000000",
        address: "Kathmandu",
        avatar: "avatar.png",
      );
      when(() => mockGetProfile()).thenAnswer((_) async => Right(profile));

      final container = makeContainer();
      addTearDown(container.dispose);

      // Build provider + run microtasks
      container.read(userViewModelProvider.notifier);
      await flushMicrotasks();

      // Act
      final ok = await container
          .read(userViewModelProvider.notifier)
          .loginWithBiometrics();

      // Assert
      expect(ok, true);

      final state = container.read(userViewModelProvider);
      expect(state.status, UserStatus.authenticated);
      expect(state.userEntity, profile);
      expect(state.biometricLoading, false);

      verify(() => mockBiometricService.authenticate()).called(1);
      verify(() => mockTokenService.getToken()).called(1);
      verify(() => mockGetProfile()).called(greaterThanOrEqualTo(1));

      verify(
        () => mockUserSession.saveUserSession(
          userId: "u-1",
          email: "test@gmail.com",
          fullName: "Test User",
          username: "testuser",
          phoneNumber: "9800000000",
          address: "Kathmandu",
          profilePicture: "avatar.png", // <-- comes from profile.avatar
        ),
      ).called(1);
    },
  );

  // =========================================================
  // TEST 4: loginWithBiometrics() fails when no token stored
  // =========================================================
  test('loginWithBiometrics -> no token -> error, returns false', () async {
    when(() => mockBiometricService.canCheck()).thenAnswer((_) async => true);
    when(() => mockBiometricPref.isEnabled()).thenReturn(true);
    when(
      () => mockBiometricService.authenticate(),
    ).thenAnswer((_) async => true);

    // No token
    when(() => mockTokenService.getToken()).thenAnswer((_) async => null);

    final container = makeContainer();
    addTearDown(container.dispose);

    container.read(userViewModelProvider.notifier);
    await flushMicrotasks();

    final ok = await container
        .read(userViewModelProvider.notifier)
        .loginWithBiometrics();

    expect(ok, false);

    final state = container.read(userViewModelProvider);
    expect(state.status, UserStatus.error);
    expect(
      state.errorMessage,
      "No saved session. Please login with password once.",
    );
    expect(state.biometricLoading, false);

    verify(() => mockBiometricService.authenticate()).called(1);
    verify(() => mockTokenService.getToken()).called(1);
    verifyNever(
      () => mockUserSession.saveUserSession(
        userId: any(named: "userId"),
        email: any(named: "email"),
        fullName: any(named: "fullName"),
        username: any(named: "username"),
        phoneNumber: any(named: "phoneNumber"),
        address: any(named: "address"),
        profilePicture: any(named: "profilePicture"),
      ),
    );
  });

  // =========================================================
  // TEST 5: requestPasswordReset() success -> resetLinkSent + message + returns true
  // =========================================================
  test(
    'requestPasswordReset success -> sets resetLinkSent and resetMessage, returns true',
    () async {
      when(
        () => mockRequestReset.call(any()),
      ).thenAnswer((_) async => const Right("Reset link sent to email"));

      final container = makeContainer();
      addTearDown(container.dispose);

      container.read(userViewModelProvider.notifier);
      await flushMicrotasks();

      final ok = await container
          .read(userViewModelProvider.notifier)
          .requestPasswordReset("test@gmail.com");

      expect(ok, true);

      final state = container.read(userViewModelProvider);
      expect(state.status, UserStatus.resetLinkSent);
      expect(state.resetMessage, "Reset link sent to email");
      expect(state.resetLoading, false);

      verify(() => mockRequestReset.call(any())).called(1);
    },
  );
}
