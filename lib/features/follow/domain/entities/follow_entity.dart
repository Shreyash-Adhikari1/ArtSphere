import 'package:artsphere/features/auth/domain/entities/user_entity.dart';
import 'package:equatable/equatable.dart';

class FollowEntity extends Equatable {
  final UserEntity? followerId;
  final UserEntity? followingId;
  final bool? isFollowActive;
  final bool? isFollowedByMe;
  final DateTime? createdAt;
  const FollowEntity({
    required this.followerId,
    required this.followingId,
    this.isFollowActive,
    this.isFollowedByMe,
    this.createdAt,
  });
  @override
  List<Object?> get props => [
    followerId,
    followingId,
    isFollowedByMe,
    isFollowActive,
    createdAt,
  ];
}
