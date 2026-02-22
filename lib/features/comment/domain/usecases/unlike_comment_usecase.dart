import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/usecases/app_usecase.dart';
import 'package:artsphere/features/comment/data/repositories/comment_repository.dart';
import 'package:artsphere/features/comment/domain/repositories/comment_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UnlikeCommentUsecaseParams extends Equatable {
  final String commentId;
  const UnlikeCommentUsecaseParams({required this.commentId});
  @override
  List<Object?> get props => [commentId];
}

final unlikeCommentUsecaseProvider = Provider<UnlikeCommentUsecase>((ref) {
  return UnlikeCommentUsecase(
    commentRepository: ref.read(commentRepositoryProvider),
  );
});

class UnlikeCommentUsecase
    implements UsecaseWithParams<bool, UnlikeCommentUsecaseParams> {
  final ICommentRepository _commentRepository;
  UnlikeCommentUsecase({required ICommentRepository commentRepository})
    : _commentRepository = commentRepository;
  @override
  Future<Either<Failure, bool>> call(UnlikeCommentUsecaseParams params) {
    return _commentRepository.unlikeComment(params.commentId);
  }
}
