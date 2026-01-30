import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/usecases/app_usecase.dart';
import 'package:artsphere/features/auth/domain/repositories/user_repositroy.dart';
import 'package:artsphere/features/post/data/repositories/post_repository.dart';
import 'package:artsphere/features/post/domain/entities/post_entity.dart';
import 'package:artsphere/features/post/domain/repositories/post_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreatePostUsecaseParams extends Equatable {
  final String? media;
  final String? mediaType;
  final String? caption;
  final List<String>? tags;

  const CreatePostUsecaseParams({
    this.media,
    this.mediaType,
    this.caption,
    this.tags,
  });

  @override
  List<Object?> get props => [media, mediaType, caption, tags];
}

// Create Post usecase provider
final createPostUsecaseProvider = Provider<CreatePostUsecase>((ref) {
  return CreatePostUsecase(postRepository: ref.read(postRepositoryProvider));
});

class CreatePostUsecase
    implements UsecaseWithParams<bool, CreatePostUsecaseParams> {
  final IPostRepository _postRepository;
  CreatePostUsecase({required IPostRepository postRepository})
    : _postRepository = postRepository;

  @override
  Future<Either<Failure, bool>> call(CreatePostUsecaseParams params) {
    final postEntity = PostEntity(
      media: params.media,
      mediaType: params.mediaType,
      caption: params.caption,
      tags: params.tags,
    );
    return _postRepository.createPost(postEntity);
  }
}
