import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/services/connectivity/network_info.dart';
import 'package:artsphere/features/auth/data/datasources/local/user_local_datasource.dart';
import 'package:artsphere/features/auth/data/datasources/remote/user_remote_datasource.dart';
import 'package:artsphere/features/auth/data/datasources/user_datasource.dart';
import 'package:artsphere/features/auth/data/models/edit_user/edit_profile_api_model.dart';
import 'package:artsphere/features/auth/data/models/user/user_api_model.dart';
import 'package:artsphere/features/auth/data/models/hive/user_hive_model.dart';
import 'package:artsphere/features/auth/domain/entities/user_entity.dart';
import 'package:artsphere/features/auth/domain/repositories/user_repositroy.dart';
import 'package:artsphere/features/auth/domain/usecases/edit_profile_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userRepositoryProvider = Provider<IUserRepository>((ref) {
  final userLocalDatasource = ref.read(userLocalDatasourceProvider);
  final userRemoteDatasource = ref.read(userRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return UserRepository(
    userLocalDataSource: userLocalDatasource,
    userRemoteDatasource: userRemoteDatasource,
    networkInfo: networkInfo,
  );
});

class UserRepository implements IUserRepository {
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
        final apiModel = await _userRemoteDatasource.loginUser(email, password);
        if (apiModel != null) {
          final entity = apiModel.toEntity();
          return Right(entity);
        }
        return const Left(ApiFailure(message: "Invalid Credentials"));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? "login Failed",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
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
  Future<Either<Failure, bool>> logout({bool preserveToken = false}) async {
    try {
      final result = await _userLocalDatasource.logout(
        preserveToken: preserveToken,
      );
      if (result) return const Right(true);
      return Left(LocalDatabaseFailure(message: "Cannot Log User Out"));
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
        return Left(ApiFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> editProfile(
    EditProfileUsecaseParams params,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = EditProfileApiModel(
          fullName: params.fullName,
          username: params.username,
          avatar: params.avatar,
          address: params.address,
          phoneNumber: params.phoneNumber,
        );
        await _userRemoteDatasource.editProfile(apiModel);
        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? "Edit Profile Failed",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: "Internet Required To Edit Profile"));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getMyProfile() async {
    if (await _networkInfo.isConnected) {
      try {
        final user = await _userRemoteDatasource.getMyProfile();

        if (user != null) {
          final hiveModel = UserHiveModel(
            userId: user.id,
            email: user.email,
            fullName: user.fullName,
            username: user.username,
            phoneNumber: user.phoneNumber,
            address: user.address,
            avatar: user.avatar,
            password: null,
            confirmPassword: null,
          );

          await _userLocalDatasource.cacheMyProfile(hiveModel);

          return Right(user.toEntity());
        }

        return Left(ApiFailure(message: "Could not get profile"));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? "Could not get profile",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final cached = await _userLocalDatasource.getCachedMyProfile();
        if (cached != null) {
          return Right(cached.toEntity());
        }
        return Left(
          LocalDatabaseFailure(message: "No cached profile available offline"),
        );
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getUsersProfile(String userId) async {
    if (await _networkInfo.isConnected) {
      try {
        final user = await _userRemoteDatasource.getUsersProfile(userId);
        if (user != null) {
          final userEntity = user.toEntity();
          return Right(userEntity);
        }
        return Left(ApiFailure(message: "Couldnot get user"));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? "Couldnt get user",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: "Internet Required To Get Feed"));
    }
  }

  @override
  Future<Either<Failure, String>> requestPasswordReset(String email) async {
    if (await _networkInfo.isConnected) {
      try {
        final msg = await _userRemoteDatasource.requestPasswordReset(email);
        return Right(msg);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
                e.response?.data?["message"]?.toString() ??
                "Failed to request reset link",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(
        NetworkFailure(message: "Internet required to request reset"),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final ok = await _userRemoteDatasource.resetPassword(
          token: token,
          newPassword: newPassword,
        );
        return Right(ok);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
                e.response?.data?["message"]?.toString() ??
                "Invalid or expired token",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(
        NetworkFailure(message: "Internet required to reset password"),
      );
    }
  }
}
