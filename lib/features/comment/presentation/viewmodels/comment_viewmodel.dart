import 'package:artsphere/features/comment/domain/entities/comment_entity.dart';
import 'package:artsphere/features/comment/domain/usecases/create_comment_usecase.dart';
import 'package:artsphere/features/comment/domain/usecases/delete_comment_usecase.dart';
import 'package:artsphere/features/comment/domain/usecases/get_comments_usecase.dart';
import 'package:artsphere/features/comment/domain/usecases/like_comment_usecase.dart';
import 'package:artsphere/features/comment/domain/usecases/unlike_comment_usecase.dart';
import 'package:artsphere/features/comment/presentation/states/comment_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final commentViewModelProvider =
    NotifierProvider<CommentViewModel, CommentState>(() => CommentViewModel());

class CommentViewModel extends Notifier<CommentState> {
  late final CreateCommentUsecase _createComment;
  late final GetCommentsUsecase _getComments;
  late final LikeCommentUsecase _likeComment;
  late final UnlikeCommentUsecase _unlikeComment;
  late final DeleteCommentUsecase _deleteComment;

  @override
  CommentState build() {
    _createComment = ref.read(createCommentUsecaseProvider);
    _getComments = ref.read(getCommentsUsecaseProvider);
    _likeComment = ref.read(likeCommentUsecaseProvider);
    _unlikeComment = ref.read(unlikeCommentUsecaseProvider);
    _deleteComment = ref.read(deleteCommentUsecaseProvider);
    return const CommentState();
  }

  // Helpers
  void clearError() => state = state.copyWith(clearError: true);

  bool _isLikeBusy(String commentId) => state.likeBusy[commentId] == true;

  void _setLikeBusy(String commentId, bool busy) {
    final next = {...state.likeBusy, commentId: busy};
    state = state.copyWith(likeBusy: next);
  }

  List<CommentEntity> _removeCommentFromList(
    List<CommentEntity> list,
    String commentId,
  ) {
    return list.where((c) => c.commentId != commentId).toList();
  }

  List<CommentEntity> _replaceCommentInList(
    List<CommentEntity> list,
    CommentEntity updated,
  ) {
    return list
        .map(
          (c) => (c.commentId != null && c.commentId == updated.commentId)
              ? updated
              : c,
        )
        .toList();
  }

  // -----------------------
  // Load comments for a post
  // -----------------------
  Future<void> loadComments(String postId) async {
    // mark which post's comments we are viewing
    state = state.copyWith(
      commentsLoading: true,
      clearError: true,
      activePostId: postId,
      comments:
          const [], // optional: clear old comments immediately when switching posts
    );

    try {
      final result = await _getComments(
        GetCommentsUsecaseParams(postId: postId),
      );

      // if user switched posts while request was in-flight, ignore this response
      if (state.activePostId != postId) return;

      result.fold(
        (failure) => state = state.copyWith(errorMessage: failure.message),
        (comments) => state = state.copyWith(comments: comments),
      );
    } catch (e) {
      if (state.activePostId != postId) return;
      state = state.copyWith(errorMessage: e.toString());
    } finally {
      if (state.activePostId == postId) {
        state = state.copyWith(commentsLoading: false);
      }
    }
  }

  // -----------------------
  // Create comment (optimistic prepend)
  // -----------------------
  Future<CommentEntity?> createComment({
    required String postId,
    required String commentText,
  }) async {
    state = state.copyWith(
      actionLoading: true,
      clearError: true,
      activePostId: postId,
    );

    final params = CreateCommentUsecaseParams(
      postId: postId,
      commentText: commentText,
    );
    final result = await _createComment(params);

    return result.fold(
      (failure) {
        state = state.copyWith(
          actionLoading: false,
          errorMessage: failure.message,
        );
        return null;
      },
      (created) {
        // only add if we're still on same post
        if (state.activePostId == postId) {
          state = state.copyWith(
            actionLoading: false,
            comments: [created, ...state.comments],
          );
        } else {
          state = state.copyWith(actionLoading: false);
        }
        return created;
      },
    );
  }

  // -----------------------
  // Delete comment (optimistic remove)
  // -----------------------
  Future<bool> deleteComment(String commentId) async {
    state = state.copyWith(actionLoading: true, clearError: true);

    final oldComments = state.comments;
    state = state.copyWith(
      comments: _removeCommentFromList(oldComments, commentId),
    );

    final result = await _deleteComment(
      DeleteCommentUsecaseParams(commentId: commentId),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          actionLoading: false,
          comments: oldComments,
          errorMessage: failure.message,
        );
        return false;
      },
      (ok) {
        state = state.copyWith(actionLoading: false);
        return ok;
      },
    );
  }

  // -----------------------
  // Like / Unlike comment (optimistic)
  // -----------------------
  Future<void> toggleLike({
    required CommentEntity comment,
    required bool currentlyLiked,
    required String myUserId,
  }) async {
    final commentId = comment.commentId;
    if (commentId == null) return;
    if (_isLikeBusy(commentId)) return;

    _setLikeBusy(commentId, true);
    clearError();

    try {
      final currentLikeCount = comment.likeCount ?? 0;
      final newLikeCount = currentlyLiked
          ? (currentLikeCount - 1).clamp(0, 999999)
          : currentLikeCount + 1;

      final oldLikedBy = comment.likedBy ?? const [];
      final newLikedBy = currentlyLiked
          ? oldLikedBy.where((id) => id != myUserId).toList()
          : [...oldLikedBy, myUserId];

      final updated = CommentEntity(
        commentId: comment.commentId,
        postId: comment.postId,
        userId: comment.userId,
        commentText: comment.commentText,
        likeCount: newLikeCount,
        likedBy: newLikedBy,
        createdAt: comment.createdAt,
      );

      state = state.copyWith(
        comments: _replaceCommentInList(state.comments, updated),
      );

      final result = currentlyLiked
          ? await _unlikeComment(
              UnlikeCommentUsecaseParams(commentId: commentId),
            )
          : await _likeComment(LikeCommentUsecaseParams(commentId: commentId));

      result.fold((failure) {
        // rollback
        state = state.copyWith(
          comments: _replaceCommentInList(state.comments, comment),
          errorMessage: failure.message,
        );
      }, (_) {});
    } catch (e) {
      // rollback on unexpected errors too
      state = state.copyWith(
        comments: _replaceCommentInList(state.comments, comment),
        errorMessage: e.toString(),
      );
    } finally {
      _setLikeBusy(commentId, false);
    }
  }
}
