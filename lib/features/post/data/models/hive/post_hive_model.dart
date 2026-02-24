import 'package:artsphere/core/constants/hive_table_constant.dart';
import 'package:artsphere/features/auth/domain/entities/user_entity.dart';
import 'package:artsphere/features/post/data/models/post_api_model.dart';
import 'package:artsphere/features/post/domain/entities/post_entity.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

part 'post_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.postTypeId)
class PostHiveModel extends HiveObject {
  @HiveField(0)
  final String postId;

  @HiveField(1)
  final String? authorId;

  @HiveField(2)
  final String? authorUsername;

  @HiveField(3)
  final String? authorAvatar;

  @HiveField(4)
  final String? media;

  @HiveField(5)
  final String? mediaType;

  @HiveField(6)
  final String? caption;

  @HiveField(7)
  final List<String>? tags;

  @HiveField(8)
  final String? visibility;

  @HiveField(9)
  final int? likeCount;

  @HiveField(10)
  final List<String>? likedBy;

  @HiveField(11)
  final int? commentCount;

  @HiveField(12)
  final List<String>? commentedBy;

  @HiveField(13)
  final bool? isChallengeSubmission;

  @HiveField(14)
  final DateTime? createdAt;

  PostHiveModel({
    required this.postId,
    this.authorId,
    this.authorUsername,
    this.authorAvatar,
    this.media,
    this.mediaType,
    this.caption,
    this.tags,
    this.visibility,
    this.likeCount,
    this.likedBy,
    this.commentCount,
    this.commentedBy,
    this.isChallengeSubmission,
    this.createdAt,
  });

  PostEntity toEntity() {
    return PostEntity(
      postId: postId,
      author:
          (authorId == null && authorUsername == null && authorAvatar == null)
          ? null
          : UserEntity.preview(
              userId: authorId,
              username: authorUsername ?? "",
              avatar: authorAvatar,
            ),
      media: media,
      mediaType: mediaType,
      caption: caption,
      tags: tags,
      visibility: visibility,
      likeCount: likeCount,
      likedBy: likedBy,
      commentCount: commentCount,
      commentedBy: commentedBy,
      isChallengeSubmission: isChallengeSubmission,
      createdAt: createdAt,
    );
  }

  // Entity -> Hive
  factory PostHiveModel.fromEntity(PostEntity post) {
    return PostHiveModel(
      postId: post.postId ?? "", 
      authorId: post.author?.userId,
      authorUsername: post.author?.username,
      authorAvatar: post.author?.avatar,
      media: post.media,
      mediaType: post.mediaType,
      caption: post.caption,
      tags: post.tags,
      visibility: post.visibility,
      likeCount: post.likeCount,
      likedBy: post.likedBy,
      commentCount: post.commentCount,
      commentedBy: post.commentedBy,
      isChallengeSubmission: post.isChallengeSubmission,
      createdAt: post.createdAt,
    );
  }

  // Api -> Hive (handy for repository caching)
  factory PostHiveModel.fromApi(PostApiModel api) {
    return PostHiveModel(
      postId: api.postId ?? "",
      authorId: api.author?.id,
      authorUsername: api.author?.username,
      authorAvatar: api.author?.avatar,
      media: api.media,
      mediaType: api.mediaType,
      caption: api.caption,
      tags: api.tags,
      visibility: api.visibility,
      likeCount: api.likeCount,
      likedBy: api.likedBy,
      commentCount: api.commentCount,
      commentedBy: api.commentedBy,
      isChallengeSubmission: api.isChallengeSubmission,
      createdAt: api.createdAt,
    );
  }

  static List<PostEntity> toEntityList(List<PostHiveModel> models) {
    return models.map((m) => m.toEntity()).toList();
  }
}
