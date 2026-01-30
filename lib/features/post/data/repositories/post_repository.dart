import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/services/connectivity/network_info.dart';
import 'package:artsphere/features/post/data/datasources/post_datasource.dart';
import 'package:artsphere/features/post/data/datasources/remote/post_remote_datasource.dart';
import 'package:artsphere/features/post/data/models/post/post_api_model.dart';
import 'package:artsphere/features/post/domain/entities/post_entity.dart';
import 'package:artsphere/features/post/domain/repositories/post_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// post repository provider
final postRepositoryProvider = Provider<IPostRepository>((ref) {
  final postRemoteDatasource = ref.read(postRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return PostRepository(
    postRemoteDatasource: postRemoteDatasource,
    networkInfo: networkInfo,
  );
});

class PostRepository implements IPostRepository {
  final IPostRemoteDatasource _postRemoteDatasource;
  final NetworkInfo _networkInfo;

  PostRepository({
    required IPostRemoteDatasource postRemoteDatasource,
    required NetworkInfo networkInfo,
  }) : _networkInfo = networkInfo,
       _postRemoteDatasource = postRemoteDatasource;
  @override
  Future<Either<Failure, PostEntity>> commentOnPost(
    String postId,
    String userId,
  ) {
    // TODO: implement commentOnPost
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> createPost(PostEntity post) async {
    if (await _networkInfo.isConnected) {
      try {
        final postApiModel = PostApiModel.fromEntity(post);
        await _postRemoteDatasource.createPost(postApiModel);
        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? "Failed to create post",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: "Internet Required To Create Post"));
    }
  }

  @override
  Future<Either<Failure, PostEntity>> deleteComment(
    String postId,
    String userId,
  ) {
    // TODO: implement deleteComment
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, PostEntity>> deletePost(String postId) {
    // TODO: implement deletePost
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<PostEntity>>> getMyPosts(String userId) {
    // TODO: implement getMyPosts
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, PostEntity>> likePost(String postId, String userId) {
    // TODO: implement likePost
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, PostEntity>> unlikePost(String postId, String userId) {
    // TODO: implement unlikePost
    throw UnimplementedError();
  }
}
