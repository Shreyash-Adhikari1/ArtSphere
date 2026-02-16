import 'package:artsphere/features/post/domain/entities/post_entity.dart';
import 'package:equatable/equatable.dart';

enum PostStatus { initial, loading, loaded, created, error }

class PostState extends Equatable {
  final PostStatus status;
  final PostEntity? postEntity;
  final List<PostEntity> posts;
  final String? errorMessage;
  const PostState({
    this.status = PostStatus.initial,
    this.postEntity,
    this.posts = const [],
    this.errorMessage,
  });

  PostState copyWith({
    PostStatus? status,
    PostEntity? postEntity,
    List<PostEntity>? posts,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PostState(
      status: status ?? this.status,
      postEntity: postEntity ?? this.postEntity,
      posts: posts ?? this.posts,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, postEntity, posts, errorMessage];
}
