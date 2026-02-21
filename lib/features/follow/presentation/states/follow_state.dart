import 'package:artsphere/features/follow/domain/entities/follow_entity.dart';
import 'package:equatable/equatable.dart';

class FollowState extends Equatable {
  // Loading flags
  final bool loadingMyFollowers;
  final bool loadingMyFollowing;
  final bool loadingUserFollowers;
  final bool loadingUserFollowing;

  // Follow/unfollow action
  final bool actionLoading;

  // Per-user follow/unfollow lock
  final Map<String, bool> followBusy;

  // Data
  final List<FollowEntity> myFollowers;
  final List<FollowEntity> myFollowing;
  final List<FollowEntity> userFollowers;
  final List<FollowEntity> userFollowing;

  // kasko profile load bhairaaxa flag
  final String? activeUserId;

  final String? errorMessage;

  const FollowState({
    this.loadingMyFollowers = false,
    this.loadingMyFollowing = false,
    this.loadingUserFollowers = false,
    this.loadingUserFollowing = false,
    this.actionLoading = false,
    this.followBusy = const {},
    this.myFollowers = const [],
    this.myFollowing = const [],
    this.userFollowers = const [],
    this.userFollowing = const [],
    this.activeUserId,
    this.errorMessage,
  });

  FollowState copyWith({
    bool? loadingMyFollowers,
    bool? loadingMyFollowing,
    bool? loadingUserFollowers,
    bool? loadingUserFollowing,
    bool? actionLoading,
    Map<String, bool>? followBusy,
    List<FollowEntity>? myFollowers,
    List<FollowEntity>? myFollowing,
    List<FollowEntity>? userFollowers,
    List<FollowEntity>? userFollowing,
    String? activeUserId,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FollowState(
      loadingMyFollowers: loadingMyFollowers ?? this.loadingMyFollowers,
      loadingMyFollowing: loadingMyFollowing ?? this.loadingMyFollowing,
      loadingUserFollowers: loadingUserFollowers ?? this.loadingUserFollowers,
      loadingUserFollowing: loadingUserFollowing ?? this.loadingUserFollowing,
      actionLoading: actionLoading ?? this.actionLoading,
      followBusy: followBusy ?? this.followBusy,
      myFollowers: myFollowers ?? this.myFollowers,
      myFollowing: myFollowing ?? this.myFollowing,
      userFollowers: userFollowers ?? this.userFollowers,
      userFollowing: userFollowing ?? this.userFollowing,
      activeUserId: activeUserId ?? this.activeUserId,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    loadingMyFollowers,
    loadingMyFollowing,
    loadingUserFollowers,
    loadingUserFollowing,
    actionLoading,
    followBusy,
    myFollowers,
    myFollowing,
    userFollowers,
    userFollowing,
    activeUserId,
    errorMessage,
  ];
}
