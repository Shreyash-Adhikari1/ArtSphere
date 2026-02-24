import 'package:artsphere/features/post/data/models/create/create_post_api_model.dart';
import 'package:artsphere/features/submission/data/models/submission_api_model.dart';

abstract interface class ISubmissionRemoteDatasource {
  Future<SubmissionApiModel> submitExistingPost(
    String challengeId,
    String postId,
  );

  Future<SubmissionApiModel> createNewPostAndSubmit(
    String challengeId,
    CreatePostApiModel post,
    String mediaPath,
  );

  Future<List<SubmissionApiModel>> getSubmissionsForChallenge(
    String challengeId,
  );

  Future<bool> deleteSubmission(String submissionId);
}
