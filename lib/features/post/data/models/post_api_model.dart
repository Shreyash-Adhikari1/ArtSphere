import 'package:artsphere/features/post/data/models/helper/author_converter.dart';
import 'package:artsphere/features/post/data/models/post_author/post_author_api_model.dart';
import 'package:artsphere/features/post/domain/entities/post_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_api_model.g.dart';

@JsonSerializable()
class PostApiModel {
  @JsonKey(name: "_id")
  final String? postId;

  @JsonKey(fromJson: AuthorConverter.fromJson, toJson: AuthorConverter.toJson)
  final PostAuthorApiModel? author;

  final String? media;
  final String? mediaType;
  final String? caption;
  final List<String>? tags;
  final String? visibility;
  final int? likeCount;
  final List<String>? likedBy;
  final int? commentCount;
  final List<String>? commentedBy;

  const PostApiModel({
    this.postId,
    this.author,
    this.media,
    this.mediaType,
    this.caption,
    this.tags,
    this.visibility,
    this.likeCount,
    this.likedBy,
    this.commentCount,
    this.commentedBy,
  });

  factory PostApiModel.fromJson(Map<String, dynamic> json) =>
      _$PostApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$PostApiModelToJson(this);

  PostEntity toEntity() {
    return PostEntity(
      postId: postId,
      author: author?.toEntity(),
      media: media,
      mediaType: mediaType,
      caption: caption,
      tags: tags,
      visibility: visibility,
      likeCount: likeCount,
      likedBy: likedBy,
      commentCount: commentCount,
      commentedBy: commentedBy,
    );
  }

  factory PostApiModel.fromEntity(PostEntity post) {
    return PostApiModel(
      postId: post.postId,
      author: post.author == null
          ? null
          : PostAuthorApiModel(
              id: post.author!.userId,
              username: post.author!.username,
              avatar: post.author!.avatar,
            ),
      media: post.media,
      mediaType: post.mediaType,
      caption: post.caption,
      tags: post.tags,
      visibility: post.visibility,
      likeCount: post.likeCount,
      likedBy: post.likedBy,
      commentCount: post.commentCount,
      commentedBy: post.commentedBy,
    );
  }
}
