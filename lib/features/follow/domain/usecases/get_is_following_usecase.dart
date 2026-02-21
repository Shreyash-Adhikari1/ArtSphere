import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/usecases/app_usecase.dart';
import 'package:artsphere/features/follow/data/repositories/follow_repository.dart';
import 'package:artsphere/features/follow/domain/repositories/follow_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetIsFollowingParams extends Equatable {
  final String targetUserId;
  const GetIsFollowingParams({required this.targetUserId});
  @override
  List<Object?> get props => [targetUserId];
}

final getIsFollowingUsecaseProvider = Provider<GetIsFollowingUsecase>((ref) {
  return GetIsFollowingUsecase(
    followRepository: ref.read(followRepositoryProvider),
  );
});

class GetIsFollowingUsecase
    implements UsecaseWithParams<bool, GetIsFollowingParams> {
  final IFollowRepository _followRepository;
  GetIsFollowingUsecase({required IFollowRepository followRepository})
    : _followRepository = followRepository;

  @override
  Future<Either<Failure, bool>> call(GetIsFollowingParams params) {
    return _followRepository.getIsFollowingStatus(params.targetUserId);
  }
}
