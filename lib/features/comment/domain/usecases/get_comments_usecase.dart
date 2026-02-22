import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/usecases/app_usecase.dart';
import 'package:artsphere/features/comment/data/repositories/comment_repository.dart';
import 'package:artsphere/features/comment/domain/entities/comment_entity.dart';
import 'package:artsphere/features/comment/domain/repositories/comment_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetCommentsUsecaseParams extends Equatable {
  final String postId;
  const GetCommentsUsecaseParams({required this.postId});
  @override
  List<Object?> get props => [postId];
}

final getCommentsUsecaseProvider = Provider<GetCommentsUsecase>((ref) {
  return GetCommentsUsecase(
    commentRepository: ref.read(commentRepositoryProvider),
  );
});

class GetCommentsUsecase
    implements
        UsecaseWithParams<List<CommentEntity>, GetCommentsUsecaseParams> {
  final ICommentRepository _commentRepository;
  GetCommentsUsecase({required ICommentRepository commentRepository})
    : _commentRepository = commentRepository;
  @override
  Future<Either<Failure, List<CommentEntity>>> call(
    GetCommentsUsecaseParams params,
  ) {
    return _commentRepository.getCommentsForPost(params.postId);
  }
}
