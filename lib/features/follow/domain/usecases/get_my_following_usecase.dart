import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/usecases/app_usecase.dart';
import 'package:artsphere/features/follow/data/repositories/follow_repository.dart';
import 'package:artsphere/features/follow/domain/entities/follow_entity.dart';
import 'package:artsphere/features/follow/domain/repositories/follow_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getMyFollowingUsecaseProvider = Provider<GetMyFollowingUsecase>((ref) {
  return GetMyFollowingUsecase(
    followRepository: ref.read(followRepositoryProvider),
  );
});

class GetMyFollowingUsecase
    implements UsecaseWithoutParams<List<FollowEntity>> {
  final IFollowRepository _followRepository;
  GetMyFollowingUsecase({required IFollowRepository followRepository})
    : _followRepository = followRepository;
  @override
  Future<Either<Failure, List<FollowEntity>>> call() {
    final following = _followRepository.getMyFollowing();
    return following;
  }
}
