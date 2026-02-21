import 'package:artsphere/features/auth/domain/entities/user_entity.dart';
import 'package:equatable/equatable.dart';

class FollowEntity extends Equatable {
  final String? followId;
  final UserEntity? follower;
  final UserEntity? following;
  final bool? isFollowActive;
  final bool? isFollowedByMe;
  final DateTime? createdAt;
  const FollowEntity({
    this.followId,
    required this.follower,
    required this.following,
    this.isFollowActive,
    this.isFollowedByMe,
    this.createdAt,
  });
  @override
  List<Object?> get props => [
    followId,
    follower,
    following,
    isFollowedByMe,
    isFollowActive,
    createdAt,
  ];
}
