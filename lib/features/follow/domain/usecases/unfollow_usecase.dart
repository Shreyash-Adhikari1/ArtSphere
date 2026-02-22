import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/usecases/app_usecase.dart';
import 'package:artsphere/features/follow/data/repositories/follow_repository.dart';
import 'package:artsphere/features/follow/domain/entities/follow_entity.dart';
import 'package:artsphere/features/follow/domain/repositories/follow_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UnfollowUsecaseParams extends Equatable {
  final String targetUserId;
  const UnfollowUsecaseParams({required this.targetUserId});
  @override
  List<Object?> get props => [targetUserId];
}

final unfollowUsecaseProvider = Provider<UnfollowUsecase>((ref) {
  return UnfollowUsecase(followRepository: ref.read(followRepositoryProvider));
});

class UnfollowUsecase
    implements UsecaseWithParams<FollowEntity, UnfollowUsecaseParams> {
  final IFollowRepository _followRepository;
  UnfollowUsecase({required IFollowRepository followRepository})
    : _followRepository = followRepository;
  @override
  Future<Either<Failure, FollowEntity>> call(UnfollowUsecaseParams params) {
    return _followRepository.unfollow(params.targetUserId);
  }
}
