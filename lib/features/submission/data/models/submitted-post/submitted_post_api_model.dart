import 'package:artsphere/features/post/data/models/helper/author_converter.dart';
import 'package:artsphere/features/post/data/models/post_author/post_author_api_model.dart';
import 'package:artsphere/features/post/domain/entities/post_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'submitted_post_api_model.g.dart';

@JsonSerializable()
class SubmittedPostApiModel {
  @JsonKey(name: "_id")
  final String? id;

  @JsonKey(fromJson: AuthorConverter.fromJson, toJson: AuthorConverter.toJson)
  final PostAuthorApiModel? author;

  final String? media;
  final String? caption;
  final int? likeCount;
  final int? commentCount;

  const SubmittedPostApiModel({
    this.id,
    this.author,
    this.media,
    this.caption,
    this.likeCount,
    this.commentCount,
  });

  factory SubmittedPostApiModel.fromJson(Map<String, dynamic> json) =>
      _$SubmittedPostApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubmittedPostApiModelToJson(this);

  /// Convert to domain entity (preview user)
  PostEntity toEntity() {
    return PostEntity(
      postId: id,
      author: author?.toEntity(),
      media: media,
      caption: caption,
      likeCount: likeCount,
      commentCount: commentCount,
    );
  }

  // When backend gives only submittedPostId
  factory SubmittedPostApiModel.fromId(String id) {
    return SubmittedPostApiModel(id: id);
  }
}
