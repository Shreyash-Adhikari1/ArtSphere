import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/features/auth/domain/entities/user_entity.dart';
import 'package:artsphere/features/auth/domain/usecases/edit_profile_usecase.dart';
import 'package:artsphere/features/auth/domain/usecases/get_profile_usecase.dart';
import 'package:artsphere/features/auth/domain/usecases/login_usecase.dart';
import 'package:artsphere/features/auth/domain/usecases/register_usecase.dart';
import 'package:artsphere/features/auth/presentation/state/user_state.dart';
import 'package:artsphere/features/auth/presentation/viewmodels/user_view_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ---- mocks ----
class MockRegisterUsecase extends Mock implements RegisterUsecase {}

class MockLoginUsecase extends Mock implements LoginUsecase {}

class MockGetProfileUsecase extends Mock implements GetProfileUsecase {}

class MockEditProfileUsecase extends Mock implements EditProfileUsecase {}

// ---- fakes (mocktail fallback values for any()) ----
class FakeLoginParams extends Fake implements LoginUsecaseParams {}

class FakeRegisterParams extends Fake implements RegisterUsecaseParams {}

class FakeEditProfileParams extends Fake implements EditProfileUsecaseParams {}

class FakeUserEntity extends Fake implements UserEntity {}

void main() {
  late MockRegisterUsecase mockRegister;
  late MockLoginUsecase mockLogin;
  late MockGetProfileUsecase mockGetProfile;
  late MockEditProfileUsecase mockEditProfile;

  ProviderContainer makeContainer() {
    return ProviderContainer(
      overrides: [
        registerUsecaseProvider.overrideWithValue(mockRegister),
        loginUsecaseProvider.overrideWithValue(mockLogin),
        getProfileUsecaseProvider.overrideWithValue(mockGetProfile),
        editProfileUsecaseProvider.overrideWithValue(mockEditProfile),
      ],
    );
  }

  Future<void> flushMicrotasks() async {
    // Allows Future.microtask(() => getProfile()) inside build() to execute
    await Future<void>.delayed(Duration.zero);
  }

  setUpAll(() {
    // Required because you use any() with these parameter types:
    registerFallbackValue(FakeLoginParams());
    registerFallbackValue(FakeRegisterParams());
    registerFallbackValue(FakeEditProfileParams());
  });

  setUp(() {
    mockRegister = MockRegisterUsecase();
    mockLogin = MockLoginUsecase();
    mockGetProfile = MockGetProfileUsecase();
    mockEditProfile = MockEditProfileUsecase();

    // build() triggers getProfile() in a microtask, so ALWAYS stub it.
    when(
      () => mockGetProfile(),
    ).thenAnswer((_) async => Right(FakeUserEntity()));

    // Safe defaults (not the focus of most tests, but prevents unexpected crashes)
    when(
      () => mockRegister.call(any()),
    ).thenAnswer((_) async => const Right(false));
    when(
      () => mockEditProfile.call(any()),
    ).thenAnswer((_) async => const Right(false));
  });

  test('login success -> status authenticated and userEntity set', () async {
    // Arrange
    final fakeUser = FakeUserEntity();
    when(() => mockLogin(any())).thenAnswer((_) async => Right(fakeUser));

    final container = makeContainer();
    addTearDown(container.dispose);

    // Trigger provider build and let getProfile finish first
    container.read(userViewModelProvider.notifier);
    await flushMicrotasks();

    // Act
    await container
        .read(userViewModelProvider.notifier)
        .login(email: 'test@gmail.com', password: 'password123');

    // Assert
    final state = container.read(userViewModelProvider);
    expect(state.status, UserStatus.authenticated);
    expect(state.userEntity, fakeUser);
    expect(state.errorMessage, isNull);

    verify(() => mockLogin(any())).called(1);
  });

  test('login failure -> status error and errorMessage set', () async {
    // Arrange
    const failure = ApiFailure(message: 'Invalid credentials', statusCode: 401);
    when(() => mockLogin(any())).thenAnswer((_) async => const Left(failure));

    final container = makeContainer();
    addTearDown(container.dispose);

    container.read(userViewModelProvider.notifier);
    await flushMicrotasks();

    // Act
    await container
        .read(userViewModelProvider.notifier)
        .login(email: 'bad@gmail.com', password: 'wrong');

    // Assert
    final state = container.read(userViewModelProvider);
    expect(state.status, UserStatus.error);
    expect(state.errorMessage, failure.message);

    verify(() => mockLogin(any())).called(1);
  });

  test('register success (true) -> status registered', () async {
    // Arrange
    when(
      () => mockRegister.call(any()),
    ).thenAnswer((_) async => const Right(true));

    final container = makeContainer();
    addTearDown(container.dispose);

    container.read(userViewModelProvider.notifier);
    await flushMicrotasks();

    // Act
    await container
        .read(userViewModelProvider.notifier)
        .register(
          fullName: 'Test User',
          username: 'testuser',
          email: 'test@gmail.com',
          password: 'password123',
          confirmPassword: 'password123',
          address: 'Kathmandu',
          phoneNumber: '9800000000',
        );

    // Assert
    final state = container.read(userViewModelProvider);
    expect(state.status, UserStatus.registered);
    expect(state.errorMessage, isNull);

    verify(() => mockRegister.call(any())).called(1);
  });

  test(
    'register failure (Left) -> status error and errorMessage set',
    () async {
      // Arrange
      const failure = NetworkFailure(message: 'No internet connection');
      when(
        () => mockRegister.call(any()),
      ).thenAnswer((_) async => const Left(failure));

      final container = makeContainer();
      addTearDown(container.dispose);

      container.read(userViewModelProvider.notifier);
      await flushMicrotasks();

      // Act
      await container
          .read(userViewModelProvider.notifier)
          .register(
            fullName: 'Test User',
            username: 'testuser',
            email: 'test@gmail.com',
            password: 'password123',
            confirmPassword: 'password123',
            address: 'Kathmandu',
            phoneNumber: '9800000000',
          );

      // Assert
      final state = container.read(userViewModelProvider);
      expect(state.status, UserStatus.error);
      expect(state.errorMessage, failure.message);

      verify(() => mockRegister.call(any())).called(1);
    },
  );

  test(
    'editProfile success -> calls getProfile and ends with edited status',
    () async {
      // Arrange
      final updatedProfile = FakeUserEntity();

      // editProfile succeeds
      when(
        () => mockEditProfile.call(any()),
      ).thenAnswer((_) async => const Right(true));

      // getProfile is called twice:
      // 1) during build()
      // 2) after successful editProfile()
      when(
        () => mockGetProfile(),
      ).thenAnswer((_) async => Right(updatedProfile));

      final container = makeContainer();
      addTearDown(container.dispose);

      // Trigger provider build and let initial getProfile finish
      container.read(userViewModelProvider.notifier);
      await flushMicrotasks();

      // Act
      await container
          .read(userViewModelProvider.notifier)
          .editProfile(
            fullName: 'Updated Name',
            username: 'updatedUser',
            address: 'Lalitpur',
            phoneNumber: '9811111111',
          );

      // Assert
      final state = container.read(userViewModelProvider);

      expect(state.status, UserStatus.edited);
      expect(state.userEntity, updatedProfile);
      expect(state.errorMessage, isNull);

      verify(() => mockEditProfile.call(any())).called(1);

      // getProfile should be called at least once after edit success
      verify(() => mockGetProfile()).called(greaterThanOrEqualTo(2));
    },
  );
}
