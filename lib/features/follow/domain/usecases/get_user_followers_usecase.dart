import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/usecases/app_usecase.dart';
import 'package:artsphere/features/follow/data/repositories/follow_repository.dart';
import 'package:artsphere/features/follow/domain/entities/follow_entity.dart';
import 'package:artsphere/features/follow/domain/repositories/follow_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetUserFollowersUsecaseParams extends Equatable {
  final String userId;
  const GetUserFollowersUsecaseParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}

final getUserFollowersUsecaseProvider = Provider<GetUserFollowersUsecase>((
  ref,
) {
  return GetUserFollowersUsecase(
    followRepository: ref.read(followRepositoryProvider),
  );
});

class GetUserFollowersUsecase
    implements
        UsecaseWithParams<List<FollowEntity>, GetUserFollowersUsecaseParams> {
  final IFollowRepository _followRepository;
  GetUserFollowersUsecase({required IFollowRepository followRepository})
    : _followRepository = followRepository;
  @override
  Future<Either<Failure, List<FollowEntity>>> call(
    GetUserFollowersUsecaseParams params,
  ) {
    final followers = _followRepository.getUsersFollowers(params.userId);
    return followers;
  }
}
