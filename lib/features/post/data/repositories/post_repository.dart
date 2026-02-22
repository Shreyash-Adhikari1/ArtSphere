import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/services/connectivity/network_info.dart';
import 'package:artsphere/features/post/data/datasources/post_datasource.dart';
import 'package:artsphere/features/post/data/datasources/remote/post_remote_datasource.dart';
import 'package:artsphere/features/post/data/models/create/create_post_api_model.dart';
import 'package:artsphere/features/post/data/models/edit/edit_post_api_model.dart';
import 'package:artsphere/features/post/data/models/post_api_model.dart';
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
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: "Internet required to create post"));
    }
  }

  @override
  Future<Either<Failure, bool>> editPost(EditPostUsecaseParams params) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = EditPostApiModel(
          caption: params.caption,
          tags: params.tags,
          visibility: params.visibility,
        );
        if (params.postId.trim().isEmpty) {
          return Left(ApiFailure(message: "PostId is required"));
        }
        await _postRemoteDatasource.editPost(params.postId, apiModel);
        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? "Edit Post Failed",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: "Internet Required To Edit Post"));
    }
  }

  @override
  Future<Either<Failure, List<PostEntity>>> getFeed() async {
    if (await _networkInfo.isConnected) {
      try {
        final posts = await _postRemoteDatasource.getFeed();
        final postEntity = PostApiModel.toEntityList(posts);
        return Right(postEntity);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? "Failed To Get Feed",
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
  Future<Either<Failure, List<PostEntity>>> getFollowingFeed() async {
    if (await _networkInfo.isConnected) {
      try {
        final followingPosts = await _postRemoteDatasource.getFollowingFeed();
        final postEntities = PostApiModel.toEntityList(followingPosts);
        return Right(postEntities);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
                e.response?.data['message'] ?? "Failed To Get Following Feed",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(
        NetworkFailure(message: "Internet Required To Get Following Feed"),
      );
    }
  }

  @override
  Future<Either<Failure, List<PostEntity>>> getMyPosts() async {
    if (await _networkInfo.isConnected) {
      try {
        final userPosts = await _postRemoteDatasource.getMyPosts();
        final userPostsEntities = PostApiModel.toEntityList(userPosts);
        return Right(userPostsEntities);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? "Failed To Get Your Posts",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(
        NetworkFailure(message: "Internet Required To Get Your Posts"),
      );
    }
  }

  @override
  Future<Either<Failure, List<PostEntity>>> getUsersPosts(String userId) async {
    if (await _networkInfo.isConnected) {
      try {
        final userPosts = await _postRemoteDatasource.getPostsByUser(userId);
        final userPostsEntities = PostApiModel.toEntityList(userPosts);
        return Right(userPostsEntities);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? "Failed To Get Users Posts",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(
        NetworkFailure(message: "Internet Required To Get Users Posts"),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> deletePost(String postId) async {
    if (await _networkInfo.isConnected) {
      try {
        await _postRemoteDatasource.deletePost(postId);
        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? "Failed To Delete Post",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: "Internet Required To Delete Post"));
    }
  }

  @override
  Future<Either<Failure, bool>> likePost(String postId) async {
    if (await _networkInfo.isConnected) {
      try {
        await _postRemoteDatasource.likePost(postId);
        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? "Failed To Like Post",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: "Internet Required To Like Post"));
    }
  }

  @override
  Future<Either<Failure, bool>> unlikePost(String postId) async {
    if (await _networkInfo.isConnected) {
      try {
        await _postRemoteDatasource.unlikePost(postId);
        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? "Failed To Unlike Post",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: "Internet Required To Unlike Post"));
    }
  }
}
