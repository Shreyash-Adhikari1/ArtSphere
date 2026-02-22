import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/usecases/app_usecase.dart';
import 'package:artsphere/features/post/data/repositories/post_repository.dart';
import 'package:artsphere/features/post/domain/repositories/post_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditPostUsecaseParams extends Equatable {
  final String postId;
  final String? caption;
  final List<String>? tags;
  final String? visibility;
  const EditPostUsecaseParams({
    required this.postId,
    this.caption,
    this.tags,
    this.visibility,
  });
  @override
  List<Object?> get props => [caption, tags, visibility];
}

final editPostUsecaseProvider = Provider<EditPostUsecase>((ref) {
  return EditPostUsecase(postRepository: ref.read(postRepositoryProvider));
});

class EditPostUsecase
    implements UsecaseWithParams<bool, EditPostUsecaseParams> {
  final IPostRepository _postRepository;
  EditPostUsecase({required IPostRepository postRepository})
    : _postRepository = postRepository;
  @override
  Future<Either<Failure, bool>> call(EditPostUsecaseParams params) {
    return _postRepository.editPost(params);
  }
}
