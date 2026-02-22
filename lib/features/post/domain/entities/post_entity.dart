import 'package:artsphere/features/auth/domain/entities/user_entity.dart';
import 'package:equatable/equatable.dart';

class PostEntity extends Equatable {
  final String? postId;
  final UserEntity? author;
  final String? media;
  final String? mediaType;
  final String? caption;
  final List<String>? tags;
  final String? visibility;
  final int? likeCount;
  final List<String>? likedBy;
  final int? commentCount;
  final List<String>? commentedBy;
  final bool? isChallengeSubmission;
  final DateTime? createdAt;

  const PostEntity({
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
    this.isChallengeSubmission,
    this.createdAt,
  });
  @override
  List<Object?> get props => [
    postId,
    author,
    media,
    mediaType,
    caption,
    tags,
    visibility,
    likeCount,
    likedBy,
    commentCount,
    commentedBy,
    isChallengeSubmission,
    createdAt,
  ];
}
