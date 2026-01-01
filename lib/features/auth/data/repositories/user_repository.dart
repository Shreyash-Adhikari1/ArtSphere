import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/features/auth/data/datasources/local/user_local_datasource.dart';
import 'package:artsphere/features/auth/data/datasources/user_datasource.dart';
import 'package:artsphere/features/auth/data/models/user_hive_model.dart';
import 'package:artsphere/features/auth/domain/entities/user_entity.dart';
import 'package:artsphere/features/auth/domain/repositories/user_repositroy.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final userRepositoryProvider= Provider<IUserRepositroy>((ref){
  final userDatasource= ref.read(userLocalDatasourceProvider);
  return UserRepository(userdataSource: userDatasource);
});


class UserRepository implements IUserRepositroy{
  final IUserDatasource _userDatasource;

  UserRepository({ required IUserDatasource userdataSource}): _userDatasource=userdataSource;

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async{
    try {
      final user= await _userDatasource.getCurrentUser();
      if (user != null) {
        final userEntity= user.toEntity();
        return Right(userEntity);
      }
      return Left(LocalDatabaseFailure(message: "Couldnot get current user"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> loginUser(String email, String password) async {
    try {
      final user= await _userDatasource.loginUser(email, password);
      if (user != null) {
        final userEntity= user.toEntity();
        return Right(userEntity);
      }
      return Left(LocalDatabaseFailure(message: "Failed to Log In User"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async{
    try {
      final result = await _userDatasource.logout();
      if (result) {
        return Right(true);
      }
      return Left(LocalDatabaseFailure(message: "Cannot Log User Out"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> registerUser(UserEntity entity) async{
    try {
      // Here We convert the incoming entity into model.
      final model = UserHiveModel.fromEntity(entity);
      final result = await _userDatasource.registerUser(model);
      if (result) {
        return Right(true);
      }
      return Left(LocalDatabaseFailure(message: "Failed to Register User"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

}