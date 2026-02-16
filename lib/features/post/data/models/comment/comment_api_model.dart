import 'package:artsphere/features/auth/data/models/user/user_api_model.dart';
import 'package:artsphere/features/post/domain/entities/comment_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment_api_model.g.dart';

@JsonSerializable()
class CommentApiModel {
  @JsonKey(name: "_id")
  final String? commentId;
  final String? postId;
  final UserApiModel? userId;
  final String commentText;
  final int? likeCount;
  final List<String>? likedBy;

  const CommentApiModel({
    this.commentId,
    this.postId,
    this.userId,
    required this.commentText,
    this.likeCount,
    this.likedBy,
  });

  // FromJson
  factory CommentApiModel.fromJson(Map<String, dynamic> json) =>
      _$CommentApiModelFromJson(json);

  // To Json
  Map<String, dynamic> toJson() => _$CommentApiModelToJson(this);

  // To Entity
  CommentEntity toEntity() {
    return CommentEntity(
      commentId: commentId,
      userId: userId?.toEntity(),
      postId: postId,
      commentText: commentText,
      likeCount: likeCount ?? 0,
      likedBy: likedBy ?? [],
    );
  }

  // From Entity
  factory CommentApiModel.fromEntity(CommentEntity comment) {
    return CommentApiModel(
      commentId: comment.commentId,
      userId: comment.userId == null
          ? null
          : UserApiModel.fromEntity(comment.userId!),
      postId: comment.postId,
      commentText: comment.commentText,
      likeCount: comment.likeCount,
      likedBy: comment.likedBy,
    );
  }

  // To Entity list
  static List<CommentEntity> toEntityList(List<CommentApiModel> model) {
    return model.map((model) => model.toEntity()).toList();
  }
}
