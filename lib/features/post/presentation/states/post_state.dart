import 'package:artsphere/features/post/domain/entities/post_entity.dart';
import 'package:equatable/equatable.dart';

class PostState extends Equatable {
  // Loading flags
  final bool discoverLoading;
  final bool followingLoading;
  final bool myPostsLoading;
  final bool userPostsLoading;
  final bool actionLoading; // create/edit/delete actions

  // Data
  final List<PostEntity> discoverPosts;
  final List<PostEntity> followingPosts;
  final List<PostEntity> myPosts;
  final List<PostEntity> userPosts;

  // Per-post "like busy" lock (so user can't spam)
  final Map<String, bool> likeBusy;

  // Error
  final String? errorMessage;

  const PostState({
    this.discoverLoading = false,
    this.followingLoading = false,
    this.myPostsLoading = false,
    this.userPostsLoading = false,
    this.actionLoading = false,
    this.discoverPosts = const [],
    this.followingPosts = const [],
    this.myPosts = const [],
    this.userPosts = const [],
    this.likeBusy = const {},
    this.errorMessage,
  });

  PostState copyWith({
    bool? discoverLoading,
    bool? followingLoading,
    bool? myPostsLoading,
    bool? userPostsLoading,
    bool? actionLoading,
    List<PostEntity>? discoverPosts,
    List<PostEntity>? followingPosts,
    List<PostEntity>? myPosts,
    List<PostEntity>? userPosts,
    Map<String, bool>? likeBusy,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PostState(
      discoverLoading: discoverLoading ?? this.discoverLoading,
      followingLoading: followingLoading ?? this.followingLoading,
      myPostsLoading: myPostsLoading ?? this.myPostsLoading,
      userPostsLoading: userPostsLoading ?? this.userPostsLoading,
      actionLoading: actionLoading ?? this.actionLoading,
      discoverPosts: discoverPosts ?? this.discoverPosts,
      followingPosts: followingPosts ?? this.followingPosts,
      myPosts: myPosts ?? this.myPosts,
      userPosts: userPosts ?? this.userPosts,
      likeBusy: likeBusy ?? this.likeBusy,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    discoverLoading,
    followingLoading,
    myPostsLoading,
    userPostsLoading,
    actionLoading,
    discoverPosts,
    followingPosts,
    myPosts,
    userPosts,
    likeBusy,
    errorMessage,
  ];
}
