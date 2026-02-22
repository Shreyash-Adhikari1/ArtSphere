import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/usecases/app_usecase.dart';
import 'package:artsphere/features/comment/data/repositories/comment_repository.dart';
import 'package:artsphere/features/comment/domain/repositories/comment_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LikeCommentUsecaseParams extends Equatable {
  final String commentId;
  const LikeCommentUsecaseParams({required this.commentId});
  @override
  List<Object?> get props => [commentId];
}

final likeCommentUsecaseProvider = Provider<LikeCommentUsecase>((ref) {
  return LikeCommentUsecase(
    commentRepository: ref.read(commentRepositoryProvider),
  );
});

class LikeCommentUsecase
    implements UsecaseWithParams<bool, LikeCommentUsecaseParams> {
  final ICommentRepository _commentRepository;
  LikeCommentUsecase({required ICommentRepository commentRepository})
    : _commentRepository = commentRepository;
  @override
  Future<Either<Failure, bool>> call(LikeCommentUsecaseParams params) {
    return _commentRepository.likeComment(params.commentId);
  }
}
