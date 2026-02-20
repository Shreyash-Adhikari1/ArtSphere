import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/usecases/app_usecase.dart';
import 'package:artsphere/features/comment/data/repositories/comment_repository.dart';
import 'package:artsphere/features/comment/domain/repositories/comment_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeleteCommentUsecaseParams extends Equatable {
  final String commentId;
  const DeleteCommentUsecaseParams({required this.commentId});
  @override
  List<Object?> get props => [commentId];
}

final deleteCommentUsecaseProvider = Provider<DeleteCommentUsecase>((ref) {
  return DeleteCommentUsecase(
    commentRepository: ref.read(commentRepositoryProvider),
  );
});

class DeleteCommentUsecase
    implements UsecaseWithParams<bool, DeleteCommentUsecaseParams> {
  final ICommentRepository _commentRepository;
  DeleteCommentUsecase({required ICommentRepository commentRepository})
    : _commentRepository = commentRepository;
  @override
  Future<Either<Failure, bool>> call(DeleteCommentUsecaseParams params) {
    return _commentRepository.deleteComment(params.commentId);
  }
}
