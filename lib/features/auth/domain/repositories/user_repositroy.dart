import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/features/auth/domain/entities/user_entity.dart';
import 'package:artsphere/features/auth/domain/usecases/edit_profile_usecase.dart';
import 'package:dartz/dartz.dart';

abstract interface class IUserRepository {
  // Auth
  Future<Either<Failure, bool>> registerUser(UserEntity entity);
  Future<Either<Failure, UserEntity>> loginUser(String email, String password);
  Future<Either<Failure, UserEntity>> getCurrentUser();
  Future<Either<Failure, bool>> logout();

  // Own Profile
  Future<Either<Failure, UserEntity>> getMyProfile();
  Future<Either<Failure, bool>> editProfile(EditProfileUsecaseParams params);

  // Other users profile
  Future<Either<Failure, UserEntity>> getUsersProfile(String userId);
}
