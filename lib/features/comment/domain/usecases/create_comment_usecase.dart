import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/usecases/app_usecase.dart';
import 'package:artsphere/features/comment/data/repositories/comment_repository.dart';
import 'package:artsphere/features/comment/domain/entities/comment_entity.dart';
import 'package:artsphere/features/comment/domain/repositories/comment_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateCommentUsecaseParams extends Equatable {
  final String postId;
  final String commentText;
  const CreateCommentUsecaseParams({
    required this.postId,
    required this.commentText,
  });

  @override
  List<Object?> get props => [postId, commentText];
}

final createCommentUsecaseProvider = Provider<CreateCommentUsecase>((ref) {
  return CreateCommentUsecase(
    commentRepository: ref.read(commentRepositoryProvider),
  );
});

class CreateCommentUsecase
    implements UsecaseWithParams<CommentEntity, CreateCommentUsecaseParams> {
  final ICommentRepository _commentRepository;
  CreateCommentUsecase({required ICommentRepository commentRepository})
    : _commentRepository = commentRepository;
  @override
  Future<Either<Failure, CommentEntity>> call(
    CreateCommentUsecaseParams params,
  ) {
    return _commentRepository.createComment(params);
  }
}
