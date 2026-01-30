import 'package:artsphere/features/auth/data/models/user_api_model.dart';
import 'package:artsphere/features/post/domain/entities/post_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_api_model.g.dart';

@JsonSerializable()
class PostApiModel {
  @JsonKey(name: "_id")
  final String? postId;
  final UserApiModel? author;
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

  // From Json [Usinbg Json Serializable]
  factory PostApiModel.fromJson(Map<String, dynamic> json) =>
      _$PostApiModelFromJson(json);
  // To Json
  Map<String, dynamic> toJson() => _$PostApiModelToJson(this);

  //   To Entity
  PostEntity toEntity() {
    return PostEntity(
      postId: postId,
      author: author?.toEntity(),
      media: media,
      mediaType: mediaType,
      caption: caption ?? "",
      tags: tags ?? [],
      visibility: visibility,
      likeCount: likeCount ?? 0,
      likedBy: likedBy ?? [],
      commentCount: commentCount ?? 0,
      commentedBy: commentedBy ?? [],
    );
  }

  //   From Entity
  factory PostApiModel.fromEntity(PostEntity post) {
    return PostApiModel(
      postId: post.postId,
      author: post.author == null
          ? null
          : UserApiModel.fromEntity(post.author!),
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

  // To Entity List
  static List<PostEntity> toEntityList(List<PostApiModel> model) {
    return model.map((model) => model.toEntity()).toList();
  }
}
