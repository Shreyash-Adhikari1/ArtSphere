import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/services/connectivity/network_info.dart';
import 'package:artsphere/features/comment/data/datasources/comment_datasource.dart';
import 'package:artsphere/features/comment/data/datasources/remote/comment_remote_datasource.dart';
import 'package:artsphere/features/comment/data/models/comment_api_model.dart';
import 'package:artsphere/features/comment/data/models/create/create_comment_api_model.dart';
import 'package:artsphere/features/comment/domain/entities/comment_entity.dart';
import 'package:artsphere/features/comment/domain/repositories/comment_repository.dart';
import 'package:artsphere/features/comment/domain/usecases/create_comment_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final commentRepositoryProvider = Provider<ICommentRepository>((ref) {
  return CommentRepository(
    commentRemoteDatasource: ref.read(commentRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class CommentRepository implements ICommentRepository {
  final ICommentRemoteDatasource _commentRemoteDatasource;
  final NetworkInfo _networkInfo;
  CommentRepository({
    required ICommentRemoteDatasource commentRemoteDatasource,
    required NetworkInfo networkInfo,
  }) : _commentRemoteDatasource = commentRemoteDatasource,
       _networkInfo = networkInfo;
  @override
  Future<Either<Failure, CommentEntity>> createComment(
    CreateCommentUsecaseParams params,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final createCommentApi = CreateCommentApiModel(
          commentText: params.commentText,
        );
        if (params.postId.isEmpty) {
          return Left(ApiFailure(message: "PostId is required"));
        }
        final createdCommentApi = await _commentRemoteDatasource.createComment(
          params.postId,
          createCommentApi,
        );
        return Right(createdCommentApi.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data["message"] ?? "Failed to create comment",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(
        NetworkFailure(message: "Internet required to create comment"),
      );
    }
  }

  @override
  Future<Either<Failure, List<CommentEntity>>> getCommentsForPost(
    String postId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        if (postId.trim().isEmpty) {
          return Left(ApiFailure(message: "PostId is required"));
        }
        final comments = await _commentRemoteDatasource.getCommentsForPost(
          postId,
        );
        final commentEntities = CommentApiModel.toEntityList(comments);
        return Right(commentEntities);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
                e.response?.data["message"] ??
                "Failed to get comment comments for post",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: "Internet required to get comments"));
    }
  }

  @override
  Future<Either<Failure, bool>> likeComment(String commentId) async {
    if (await _networkInfo.isConnected) {
      try {
        await _commentRemoteDatasource.likeComment(commentId);
        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data["message"] ?? "Failed to like comment",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: "Internet required to like comment"));
    }
  }

  @override
  Future<Either<Failure, bool>> unlikeComment(String commentId) async {
    if (await _networkInfo.isConnected) {
      try {
        await _commentRemoteDatasource.unlikeComment(commentId);
        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data["message"] ?? "Failed to unlike comment",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(
        NetworkFailure(message: "Internet required to unlike comment"),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> deleteComment(String commentId) async {
    if (await _networkInfo.isConnected) {
      try {
        await _commentRemoteDatasource.deleteComment(commentId);
        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data["message"] ?? "Failed to delete comment",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(
        NetworkFailure(message: "Internet required to delete comment"),
      );
    }
  }
}
