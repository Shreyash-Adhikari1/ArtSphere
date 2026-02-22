import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/usecases/app_usecase.dart';
import 'package:artsphere/features/follow/data/repositories/follow_repository.dart';
import 'package:artsphere/features/follow/domain/entities/follow_entity.dart';
import 'package:artsphere/features/follow/domain/repositories/follow_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FollowUsecaseParams extends Equatable {
  final String targetUserId;
  const FollowUsecaseParams({required this.targetUserId});
  @override
  List<Object?> get props => [targetUserId];
}

final followUsecaseProvider = Provider<FollowUsecase>((ref) {
  return FollowUsecase(followRepository: ref.read(followRepositoryProvider));
});

class FollowUsecase
    implements UsecaseWithParams<FollowEntity, FollowUsecaseParams> {
  final IFollowRepository _followRepository;
  FollowUsecase({required IFollowRepository followRepository})
    : _followRepository = followRepository;
  @override
  Future<Either<Failure, FollowEntity>> call(FollowUsecaseParams params) {
    return _followRepository.follow(params.targetUserId);
  }
}
