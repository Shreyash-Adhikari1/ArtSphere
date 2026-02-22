import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/usecases/app_usecase.dart';
import 'package:artsphere/features/post/data/repositories/post_repository.dart';
import 'package:artsphere/features/post/domain/entities/post_entity.dart';
import 'package:artsphere/features/post/domain/repositories/post_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreatePostUsecaseParams extends Equatable {
  final String mediaPath; // local file path (required)
  final String mediaType;
  final String? caption;
  final List<String>? tags;
  final String visibility;

  const CreatePostUsecaseParams({
    required this.mediaPath,
    this.mediaType = "image",
    this.caption,
    this.tags,
    this.visibility = "public",
  });

  @override
  List<Object?> get props => [mediaPath, mediaType, caption, tags, visibility];
}

final createPostUsecaseProvider = Provider<CreatePostUsecase>((ref) {
  return CreatePostUsecase(postRepository: ref.read(postRepositoryProvider));
});

class CreatePostUsecase
    implements UsecaseWithParams<PostEntity, CreatePostUsecaseParams> {
  final IPostRepository _postRepository;

  CreatePostUsecase({required IPostRepository postRepository})
    : _postRepository = postRepository;

  @override
  Future<Either<Failure, PostEntity>> call(CreatePostUsecaseParams params) {
    final postEntity = PostEntity(
      mediaType: params.mediaType,
      caption: params.caption,
      tags: params.tags,
      visibility: params.visibility,
    );

    return _postRepository.createPost(
      post: postEntity,
      mediaPath: params.mediaPath,
    );
  }
}
