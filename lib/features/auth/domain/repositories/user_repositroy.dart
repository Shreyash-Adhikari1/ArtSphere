import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/features/auth/domain/entities/user_entity.dart';
import 'package:dartz/dartz.dart';

abstract interface class IUserRepositroy {
  Future<Either<Failure,bool>> registerUser(UserEntity entity);
  Future<Either<Failure,UserEntity>> loginUser(String email, String password);
  Future<Either<Failure,UserEntity>> getCurrentUser();
  Future<Either<Failure,bool>> logout();
}