import 'package:artsphere/core/api/api_client.dart';
import 'package:artsphere/core/services/storage/token_service.dart';
import 'package:artsphere/features/post/data/models/create/create_post_api_model.dart';
import 'package:artsphere/features/submission/data/datasources/submission_datasource.dart';
import 'package:artsphere/features/submission/data/models/submission_api_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final submissionRemoteDatasourceProvider =
    Provider<ISubmissionRemoteDatasource>((ref) {
      return SubmissionRemoteDatasource(
        tokenService: ref.read(tokenServiceProvider),
        apiClient: ref.read(apiClientProvider),
      );
    });

class SubmissionRemoteDatasource implements ISubmissionRemoteDatasource {
  final TokenService _tokenService;
  final ApiClient _apiClient;
  SubmissionRemoteDatasource({
    required TokenService tokenService,
    required ApiClient apiClient,
  }) : _tokenService = tokenService,
       _apiClient = apiClient;

  @override
  Future<SubmissionApiModel> submitExistingPost(
    String challengeId,
    String postId,
  ) {
    // TODO: implement submitExistingPost
    throw UnimplementedError();
  }

  @override
  Future<SubmissionApiModel> createNewPostAndSubmit(
    String challengeId,
    CreatePostApiModel post,
    String mediaPath,
  ) {
    // TODO: implement createNewPostAndSubmit
    throw UnimplementedError();
  }

  @override
  Future<List<SubmissionApiModel>> getSubmissionsForChallenge(
    String challengeId,
  ) {
    // TODO: implement getSubmissionsForChallenge
    throw UnimplementedError();
  }

  @override
  Future<bool> deleteSubmission(String submissionId) {
    // TODO: implement deleteSubmission
    throw UnimplementedError();
  }
}
