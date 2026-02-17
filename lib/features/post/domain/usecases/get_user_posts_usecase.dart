import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/usecases/app_usecase.dart';
import 'package:artsphere/features/post/data/repositories/post_repository.dart';
import 'package:artsphere/features/post/domain/entities/post_entity.dart';
import 'package:artsphere/features/post/domain/repositories/post_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetUserPostsUsecaseParams extends Equatable {
  final String userId;
  const GetUserPostsUsecaseParams({required this.userId});
  @override
  List<Object?> get props => [userId];
}

final getUserPostsUsecaseProvider = Provider<GetUserPostsUsecase>((ref) {
  return GetUserPostsUsecase(postRepository: ref.read(postRepositoryProvider));
});

class GetUserPostsUsecase
    implements UsecaseWithParams<List<PostEntity>, GetUserPostsUsecaseParams> {
  final IPostRepository _postRepository;
  GetUserPostsUsecase({required IPostRepository postRepository})
    : _postRepository = postRepository;

  @override
  Future<Either<Failure, List<PostEntity>>> call(
    GetUserPostsUsecaseParams params,
  ) {
    final posts = _postRepository.getUsersPosts(params.userId);
    return posts;
  }
}
