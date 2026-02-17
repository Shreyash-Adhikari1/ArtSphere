import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/usecases/app_usecase.dart';
import 'package:artsphere/features/post/data/repositories/post_repository.dart';
import 'package:artsphere/features/post/domain/repositories/post_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UnlikePostUsecaseParams extends Equatable {
  final String postId;
  const UnlikePostUsecaseParams({required this.postId});

  @override
  List<Object?> get props => [postId];
}

final unlikePostUsecaseProvider = Provider<UnlikePostUsecase>((ref) {
  return UnlikePostUsecase(postRepository: ref.read(postRepositoryProvider));
});

class UnlikePostUsecase
    implements UsecaseWithParams<bool, UnlikePostUsecaseParams> {
  final IPostRepository _postRepository;
  UnlikePostUsecase({required IPostRepository postRepository})
    : _postRepository = postRepository;
  @override
  Future<Either<Failure, bool>> call(UnlikePostUsecaseParams params) {
    return _postRepository.unlikePost(params.postId);
  }
}
