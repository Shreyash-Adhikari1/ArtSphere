import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/features/auth/domain/entities/user_entity.dart';
import 'package:artsphere/features/auth/domain/repositories/user_repositroy.dart';
import 'package:artsphere/features/auth/domain/usecases/edit_profile_usecase.dart';
import 'package:artsphere/features/auth/domain/usecases/get_profile_usecase.dart';
import 'package:artsphere/features/auth/domain/usecases/login_usecase.dart';
import 'package:artsphere/features/auth/domain/usecases/register_usecase.dart';
import 'package:artsphere/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock Repository
class MockUserRepository extends Mock implements IUserRepository {}

class FakeUserEntity extends Fake implements UserEntity {}

class FakeEditProfileParams extends Fake implements EditProfileUsecaseParams {}

void main() {
  late MockUserRepository repo;

  // Usecases
  late LoginUsecase loginUsecase;
  late RegisterUsecase registerUsecase;
  late GetProfileUsecase getProfileUsecase;
  late EditProfileUsecase editProfileUsecase;
  late ResetPasswordUsecase resetPasswordUsecase;

  setUp(() {
    repo = MockUserRepository();

    loginUsecase = LoginUsecase(userRepository: repo);
    registerUsecase = RegisterUsecase(userRepository: repo);
    getProfileUsecase = GetProfileUsecase(userRepository: repo);
    editProfileUsecase = EditProfileUsecase(userRepository: repo);
    resetPasswordUsecase = ResetPasswordUsecase(userRepository: repo);
  });

  setUpAll(() {
    registerFallbackValue(FakeUserEntity());
    registerFallbackValue(FakeEditProfileParams());
  });

  const user = UserEntity(
    userId: "u1",
    fullName: "Test User",
    username: "testuser",
    email: "test@gmail.com",
    password: "",
    confirmPassword: "",
  );

  group('LoginUsecase', () {
    test(
      'calls repo.loginUser(email, password) and returns Right(UserEntity)',
      () async {
        when(
          () => repo.loginUser("test@gmail.com", "pass123"),
        ).thenAnswer((_) async => const Right(user));

        final result = await loginUsecase(
          const LoginUsecaseParams(
            email: "test@gmail.com",
            password: "pass123",
          ),
        );

        expect(result, const Right(user));
        verify(() => repo.loginUser("test@gmail.com", "pass123")).called(1);
        verifyNoMoreInteractions(repo);
      },
    );

    test('returns Left(Failure) when repo fails', () async {
      const failure = ApiFailure(
        message: "Invalid Credentials",
        statusCode: 401,
      );

      when(
        () => repo.loginUser("bad@gmail.com", "wrong"),
      ).thenAnswer((_) async => const Left(failure));

      final result = await loginUsecase(
        const LoginUsecaseParams(email: "bad@gmail.com", password: "wrong"),
      );

      expect(result, const Left(failure));
      verify(() => repo.loginUser("bad@gmail.com", "wrong")).called(1);
      verifyNoMoreInteractions(repo);
    });
  });

  group('RegisterUsecase', () {
    test('calls repo.registerUser(entity) and returns Right(true)', () async {
      when(
        () => repo.registerUser(any()),
      ).thenAnswer((_) async => const Right(true));

      final result = await registerUsecase(
        const RegisterUsecaseParams(
          fullName: "Test User",
          username: "testuser",
          email: "test@gmail.com",
          password: "",
          confirmPassword: "",
          address: null,
          phoneNumber: null,
        ),
      );

      expect(result, const Right(true));

      verify(() => repo.registerUser(any(that: isA<UserEntity>()))).called(1);
    });
  });

  group('GetProfileUsecase', () {
    test('calls repo.getMyProfile() and returns Right(UserEntity)', () async {
      when(
        () => repo.getMyProfile(),
      ).thenAnswer((_) async => const Right(user));

      final result = await getProfileUsecase();

      expect(result, const Right(user));
      verify(() => repo.getMyProfile()).called(1);
      verifyNoMoreInteractions(repo);
    });
  });

  group('EditProfileUsecase', () {
    test('calls repo.editProfile(params) and returns Right(true)', () async {
      when(
        () => repo.editProfile(any()),
      ).thenAnswer((_) async => const Right(true));

      final params = const EditProfileUsecaseParams(
        fullName: "Updated",
        username: "updatedUser",
        avatar: "avatar.png",
        address: "Kathmandu",
        phoneNumber: "9800000000",
      );

      final result = await editProfileUsecase(params);

      expect(result, const Right(true));

      verify(
        () => repo.editProfile(
          any(
            that: isA<EditProfileUsecaseParams>()
                .having((p) => p.fullName, 'fullName', "Updated")
                .having((p) => p.username, 'username', "updatedUser"),
          ),
        ),
      ).called(1);
    });
  });

  group('ResetPasswordUsecase', () {
    test(
      'calls repo.resetPassword(token, newPassword) and returns Right(true)',
      () async {
        when(
          () => repo.resetPassword(token: "t1", newPassword: "newPass"),
        ).thenAnswer((_) async => const Right(true));

        final result = await resetPasswordUsecase(
          const ResetPasswordParams(token: "t1", newPassword: "newPass"),
        );

        expect(result, const Right(true));
        verify(
          () => repo.resetPassword(token: "t1", newPassword: "newPass"),
        ).called(1);
        verifyNoMoreInteractions(repo);
      },
    );

    test('returns Left(Failure) when repo fails', () async {
      const failure = ApiFailure(
        message: "Invalid or expired token",
        statusCode: 400,
      );

      when(
        () => repo.resetPassword(token: "bad", newPassword: "newPass"),
      ).thenAnswer((_) async => const Left(failure));

      final result = await resetPasswordUsecase(
        const ResetPasswordParams(token: "bad", newPassword: "newPass"),
      );

      expect(result, const Left(failure));
      verify(
        () => repo.resetPassword(token: "bad", newPassword: "newPass"),
      ).called(1);
      verifyNoMoreInteractions(repo);
    });
  });
}
