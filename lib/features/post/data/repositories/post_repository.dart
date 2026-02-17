import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/services/connectivity/network_info.dart';
import 'package:artsphere/features/post/data/datasources/post_datasource.dart';
import 'package:artsphere/features/post/data/datasources/remote/post_remote_datasource.dart';
import 'package:artsphere/features/post/data/models/create/create_post_api_model.dart';
import 'package:artsphere/features/post/domain/entities/post_entity.dart';
import 'package:artsphere/features/post/domain/repositories/post_repository.dart';
import 'package:artsphere/features/post/domain/usecases/edit_post_usecase.dart';
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
  Future<Either<Failure, PostEntity>> createPost({
    required PostEntity post,
    required String mediaPath,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final createPostApi = CreatePostApiModel(
          caption: post.caption,
          mediaType: post.mediaType ?? "image",
          tags: post.tags ?? const [],
          visibility: post.visibility ?? "public",
        );

        final createdApi = await _postRemoteDatasource.createPost(
          createPostApi,
          mediaPath,
        );

        return Right(createdApi.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data["message"] ?? "Failed to create post",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: "Internet required to create post"));
    }
  }

  @override
  Future<Either<Failure, bool>> deletePost(String postId) {
    // TODO: implement deletePost
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> editPost(EditPostUsecaseParams params) {
    // TODO: implement editPost
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<PostEntity>>> getFeed() {
    // TODO: implement getFeed
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<PostEntity>>> getFollowingFeed() {
    // TODO: implement getFollowingFeed
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<PostEntity>>> getMyPosts() {
    // TODO: implement getMyPosts
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<PostEntity>>> getUsersPosts(String userId) {
    // TODO: implement getUsersPosts
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
