import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/services/connectivity/network_info.dart';
import 'package:artsphere/features/auth/data/datasources/local/user_local_datasource.dart';
import 'package:artsphere/features/auth/data/datasources/remote/user_remote_datasource.dart';
import 'package:artsphere/features/auth/data/datasources/user_datasource.dart';
import 'package:artsphere/features/auth/data/models/user_api_model.dart';
import 'package:artsphere/features/auth/data/models/user_hive_model.dart';
import 'package:artsphere/features/auth/domain/entities/user_entity.dart';
import 'package:artsphere/features/auth/domain/repositories/user_repositroy.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userRepositoryProvider = Provider<IUserRepositroy>((ref) {
  final userLocalDatasource = ref.read(userLocalDatasourceProvider);
  final userRemoteDatasource = ref.read(userRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return UserRepository(
    userLocalDataSource: userLocalDatasource,
    userRemoteDatasource: userRemoteDatasource,
    networkInfo: networkInfo,
  );
});

class UserRepository implements IUserRepositroy {
  final IUserLocalDatasource _userLocalDatasource;
  final IUserRemoteDatasource _userRemoteDatasource;
  final NetworkInfo _networkInfo;

  UserRepository({
    required IUserLocalDatasource userLocalDataSource,
    required IUserRemoteDatasource userRemoteDatasource,
    required NetworkInfo networkInfo,
  }) : _userLocalDatasource = userLocalDataSource,
      _userRemoteDatasource = userRemoteDatasource,
      _networkInfo = networkInfo;

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final user = await _userLocalDatasource.getCurrentUser();
      if (user != null) {
        final userEntity = user.toEntity();
        return Right(userEntity);
      }
      return Left(LocalDatabaseFailure(message: "Couldnot get current user"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> loginUser(
    String email,
    String password,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel= await _userRemoteDatasource.loginUser(email, password);
        if (apiModel!=null) {
          final entity=apiModel.toEntity();
          return Right(entity);
        }
        return const Left(ApiFailure(message: "Invalid Credentials"));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? "login Failed",
            statusCode: e.response?.statusCode
            )
        );
      }catch(e){
        return Left(
          ApiFailure(message: e.toString())
        );
      }
    } else {
      try {
        final user = await _userLocalDatasource.loginUser(email, password);
        if (user != null) {
          final userEntity = user.toEntity();
          return Right(userEntity);
        }
        return Left(LocalDatabaseFailure(message: "Failed to Log In User"));
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final result = await _userLocalDatasource.logout();
      if (result) {
        return Right(true);
      }
      return Left(LocalDatabaseFailure(message: "Cannot Log User Out"));
    } on DioException catch (e) {
      //We use DioException to catch all API errors [status codes and shit]
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? "Logout Failed",
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> registerUser(UserEntity entity) async {
    if (await _networkInfo.isConnected) {
      try {
        final apimodel = UserApiModel.fromEntity(entity);
        await _userRemoteDatasource.registerUser(apimodel);
        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? "Registration Failed",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    } else {
      try {
        // Here We convert the incoming entity into model.
        final model = UserHiveModel.fromEntity(entity);
        await _userLocalDatasource.registerUser(model);
        return Right(true);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }
}
