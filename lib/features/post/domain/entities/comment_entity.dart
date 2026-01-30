import 'package:artsphere/features/auth/domain/entities/user_entity.dart';
import 'package:equatable/equatable.dart';

class CommentEntity extends Equatable {
  final String? commentId;
  final UserEntity? userId;
  final String? postId;
  final String commentText;
  final int? likeCount;
  final List<String>? likedBy;

  const CommentEntity({
    this.commentId,
    this.userId,
    this.postId,
    required this.commentText,
    this.likeCount,
    this.likedBy,
  });
  @override
  List<Object?> get props => [
    commentId,
    userId,
    postId,
    commentText,
    likeCount,
    likedBy,
  ];
}
