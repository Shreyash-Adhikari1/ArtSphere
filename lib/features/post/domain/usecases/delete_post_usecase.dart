import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/usecases/app_usecase.dart';
import 'package:artsphere/features/post/data/repositories/post_repository.dart';
import 'package:artsphere/features/post/domain/repositories/post_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeletePostUsecaseParams extends Equatable {
  final String postId;
  const DeletePostUsecaseParams({required this.postId});
  @override
  List<Object?> get props => [postId];
}

final deletePostUsecaseProvider = Provider<DeletePostUsecase>((ref) {
  final postRepository = ref.read(postRepositoryProvider);
  return DeletePostUsecase(postRepository: postRepository);
});

class DeletePostUsecase
    implements UsecaseWithParams<bool, DeletePostUsecaseParams> {
  final IPostRepository _postRepository;
  DeletePostUsecase({required IPostRepository postRepository})
    : _postRepository = postRepository;
  @override
  Future<Either<Failure, bool>> call(DeletePostUsecaseParams params) {
    final postId = params.postId;
    return _postRepository.deletePost(postId);
  }
}
