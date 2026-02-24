import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/services/connectivity/network_info.dart';
import 'package:artsphere/features/post/data/models/create/create_post_api_model.dart';
import 'package:artsphere/features/post/domain/entities/post_entity.dart';
import 'package:artsphere/features/submission/data/datasources/remote/submission_remote_datasource.dart';
import 'package:artsphere/features/submission/data/datasources/submission_datasource.dart';
import 'package:artsphere/features/submission/data/models/submission_api_model.dart';
import 'package:artsphere/features/submission/domain/entities/submission_entity.dart';
import 'package:artsphere/features/submission/domain/repositories/submission_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final submissionRepositoryProvider = Provider<ISubmissionRepository>((ref) {
  return SubmissionRepository(
    submissionRemoteDatasource: ref.read(submissionRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class SubmissionRepository implements ISubmissionRepository {
  final ISubmissionRemoteDatasource _submissionRemoteDatasource;
  final NetworkInfo _networkInfo;

  SubmissionRepository({
    required ISubmissionRemoteDatasource submissionRemoteDatasource,
    required NetworkInfo networkInfo,
  }) : _submissionRemoteDatasource = submissionRemoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, SubmissionEntity>> submitExistingPost({
    required String challengeId,
    required String postId,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final submittedPost = await _submissionRemoteDatasource
            .submitExistingPost(challengeId, postId);
        return Right(submittedPost.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? "failed to submit post",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: "Internet required to submit post"));
    }
  }

  @override
  Future<Either<Failure, SubmissionEntity>> createNewPostAndSubmit({
    required String challengeId,
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

        final createdApi = await _submissionRemoteDatasource
            .createNewPostAndSubmit(challengeId, createPostApi, mediaPath);
        return Right(createdApi.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
                e.response?.data['message'] ??
                "Failed to create post and submit",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(
        NetworkFailure(message: "Internet Required to create post and submit "),
      );
    }
  }

  @override
  Future<Either<Failure, List<SubmissionEntity>>> getSubmissionsForChallenge(
    String challengeId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final submissions = await _submissionRemoteDatasource
            .getSubmissionsForChallenge(challengeId);
        final submissionEntities = SubmissionApiModel.toEntityList(submissions);
        return Right(submissionEntities);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
                e.response?.data['message'] ??
                "Failed to get submissions for challenge ",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(
        NetworkFailure(
          message: "Internet Required to get submissions for challenge",
        ),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> deleteSubmission(String submissionId) async {
    if (await _networkInfo.isConnected) {
      try {
        await _submissionRemoteDatasource.deleteSubmission(submissionId);
        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
                e.response?.data['message'] ?? "Failed to delete submission",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(
        NetworkFailure(message: "Internet Required to delete submission"),
      );
    }
  }
}
