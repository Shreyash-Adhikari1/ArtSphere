import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/usecases/app_usecase.dart';
import 'package:artsphere/features/post/data/repositories/post_repository.dart';
import 'package:artsphere/features/post/domain/entities/post_entity.dart';
import 'package:artsphere/features/post/domain/repositories/post_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getFollowingFeedUsecaseProvider = Provider<GetFollowingFeedUsecase>((
  ref,
) {
  final postRepository = ref.read(postRepositoryProvider);
  return GetFollowingFeedUsecase(postRepository: postRepository);
});

class GetFollowingFeedUsecase
    implements UsecaseWithoutParams<List<PostEntity>> {
  final IPostRepository _postRepository;
  GetFollowingFeedUsecase({required IPostRepository postRepository})
    : _postRepository = postRepository;
  @override
  Future<Either<Failure, List<PostEntity>>> call() {
    final posts = _postRepository.getFollowingFeed();
    return posts;
  }
}
