import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/usecases/app_usecase.dart';
import 'package:artsphere/features/follow/data/repositories/follow_repository.dart';
import 'package:artsphere/features/follow/domain/entities/follow_entity.dart';
import 'package:artsphere/features/follow/domain/repositories/follow_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetUserFollowingUsecaseParams extends Equatable {
  final String userId;
  const GetUserFollowingUsecaseParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}

final getUserFollowingUsecaseProvider = Provider<GetUserFollowingUsecase>((
  ref,
) {
  return GetUserFollowingUsecase(
    followRepository: ref.read(followRepositoryProvider),
  );
});

class GetUserFollowingUsecase
    implements
        UsecaseWithParams<List<FollowEntity>, GetUserFollowingUsecaseParams> {
  final IFollowRepository _followRepository;
  GetUserFollowingUsecase({required IFollowRepository followRepository})
    : _followRepository = followRepository;
  @override
  Future<Either<Failure, List<FollowEntity>>> call(
    GetUserFollowingUsecaseParams params,
  ) {
    final following = _followRepository.getUsersFollowing(params.userId);
    return following;
  }
}
