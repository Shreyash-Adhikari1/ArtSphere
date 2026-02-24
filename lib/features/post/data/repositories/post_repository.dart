import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/services/connectivity/network_info.dart';
import 'package:artsphere/features/post/data/datasources/local/post_local_datasource.dart';
import 'package:artsphere/features/post/data/datasources/post_datasource.dart';
import 'package:artsphere/features/post/data/datasources/remote/post_remote_datasource.dart';
import 'package:artsphere/features/post/data/models/create/create_post_api_model.dart';
import 'package:artsphere/features/post/data/models/edit/edit_post_api_model.dart';
import 'package:artsphere/features/post/data/models/hive/post_hive_model.dart';
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
  final postLocalDatasource = ref.read(postLocalDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return PostRepository(
    postRemoteDatasource: postRemoteDatasource,
    postLocalDatasource: postLocalDatasource,
    networkInfo: networkInfo,
  );
});

class PostRepository implements IPostRepository {
  final IPostLocalDatasource _postLocalDatasource;
  final IPostRemoteDatasource _postRemoteDatasource;
  final NetworkInfo _networkInfo;

  PostRepository({
    required IPostLocalDatasource postLocalDatasource,
    required IPostRemoteDatasource postRemoteDatasource,
    required NetworkInfo networkInfo,
  }) : _networkInfo = networkInfo,
       _postLocalDatasource = postLocalDatasource,
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
        final entities = PostApiModel.toEntityList(posts);

        // cache top 5
        final hiveModels = posts
            .take(5)
            .map((api) => PostHiveModel.fromApi(api))
            .toList();
        await _postLocalDatasource.cacheFeed(hiveModels, limit: 5);

        return Right(entities);
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
      // OFFLINE: return cached
      try {
        final cached = await _postLocalDatasource.getCachedFeed();
        final entities = PostHiveModel.toEntityList(cached);
        if (entities.isEmpty) {
          return Left(
            NetworkFailure(message: "No internet and no cached feed yet"),
          );
        }
        return Right(entities);
      } catch (e) {
        return Left(
          LocalDatabaseFailure(message: "Failed to load cached feed: $e"),
        );
      }
    }
  }

  @override
  Future<Either<Failure, List<PostEntity>>> getFollowingFeed() async {
    if (await _networkInfo.isConnected) {
      try {
        final posts = await _postRemoteDatasource.getFollowingFeed();
        final entities = PostApiModel.toEntityList(posts);

        final hiveModels = posts
            .take(5)
            .map((api) => PostHiveModel.fromApi(api))
            .toList();
        await _postLocalDatasource.cacheFollowingFeed(hiveModels, limit: 5);

        return Right(entities);
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
      try {
        final cached = await _postLocalDatasource.getCachedFollowingFeed();
        final entities = PostHiveModel.toEntityList(cached);
        if (entities.isEmpty) {
          return Left(
            NetworkFailure(
              message: "No internet and no cached following feed yet",
            ),
          );
        }
        return Right(entities);
      } catch (e) {
        return Left(
          LocalDatabaseFailure(
            message: "Failed to load cached following feed: $e",
          ),
        );
      }
    }
  }

  @override
  Future<Either<Failure, List<PostEntity>>> getMyPosts() async {
    if (await _networkInfo.isConnected) {
      try {
        final posts = await _postRemoteDatasource.getMyPosts();
        final entities = PostApiModel.toEntityList(posts);

        final hiveModels = posts
            .take(5)
            .map((api) => PostHiveModel.fromApi(api))
            .toList();
        await _postLocalDatasource.cacheMyPosts(hiveModels, limit: 5);

        return Right(entities);
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
      try {
        final cached = await _postLocalDatasource.getCachedMyPosts();
        final entities = PostHiveModel.toEntityList(cached);
        if (entities.isEmpty) {
          return Left(
            NetworkFailure(message: "No internet and no cached posts yet"),
          );
        }
        return Right(entities);
      } catch (e) {
        return Left(
          LocalDatabaseFailure(message: "Failed to load cached myPosts: $e"),
        );
      }
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
