import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/usecases/app_usecase.dart';
import 'package:artsphere/features/post/data/repositories/post_repository.dart';
import 'package:artsphere/features/post/domain/repositories/post_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LikePostUsecaseParams extends Equatable {
  final String postId;
  const LikePostUsecaseParams({required this.postId});

  @override
  List<Object?> get props => [postId];
}

final likePostUsecaseProvider = Provider<LikePostUsecase>((ref) {
  return LikePostUsecase(postRepository: ref.read(postRepositoryProvider));
});

class LikePostUsecase
    implements UsecaseWithParams<bool, LikePostUsecaseParams> {
  final IPostRepository _postRepository;
  LikePostUsecase({required IPostRepository postRepository})
    : _postRepository = postRepository;
  @override
  Future<Either<Failure, bool>> call(LikePostUsecaseParams params) {
    return _postRepository.likePost(params.postId);
  }
}
