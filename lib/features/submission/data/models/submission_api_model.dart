import 'package:artsphere/features/post/data/models/post_author/post_author_api_model.dart';
import 'package:artsphere/features/submission/data/models/helper/post_converter.dart';
import 'package:artsphere/features/submission/data/models/submitted-post/submitted_post_api_model.dart';
import 'package:artsphere/features/submission/domain/entities/submission_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'submission_api_model.g.dart';

@JsonSerializable()
class SubmissionApiModel {
  @JsonKey(name: "_id")
  final String? submissionId;
  final String challengeId;
  final String submitterId;

  @JsonKey(fromJson: PostConverter.fromJson, toJson: PostConverter.toJson)
  final SubmittedPostApiModel submittedPostId;

  final DateTime? createdAt;

  const SubmissionApiModel({
    this.submissionId,
    required this.challengeId,
    required this.submitterId,
    required this.submittedPostId,
    this.createdAt,
  });

  factory SubmissionApiModel.fromJson(Map<String, dynamic> json) =>
      _$SubmissionApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubmissionApiModelToJson(this);

  SubmissionEntity toEntity() {
    return SubmissionEntity(
      submissionId: submissionId,
      challengeId: challengeId,
      submitterId: submitterId,
      submittedPost: submittedPostId.toEntity(),
      createdAt: createdAt,
    );
  }

  factory SubmissionApiModel.fromEntity(SubmissionEntity submission) {
    final post = submission.submittedPost;
    final user = post.author;

    return SubmissionApiModel(
      submissionId: submission.submissionId,
      challengeId: submission.challengeId,
      submitterId: submission.submitterId,
      submittedPostId: SubmittedPostApiModel(
        id: post.postId,
        author: user == null
            ? null
            : PostAuthorApiModel(
                id: user.userId,
                username: user.username,
                avatar: user.avatar,
              ),
        media: post.media,
        caption: post.caption,
        likeCount: post.likeCount,
        commentCount: post.commentCount,
      ),
      createdAt: submission.createdAt,
    );
  }

  // to entity list
  static List<SubmissionEntity> toEntityList(List<SubmissionApiModel> model) {
    return model.map((model) => model.toEntity()).toList();
  }
}
