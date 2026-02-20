import 'package:artsphere/features/comment/domain/entities/comment_entity.dart';
import 'package:equatable/equatable.dart';

class CommentState extends Equatable {
  // Loading Flags
  final bool commentsLoading;
  final bool actionLoading;
  // Comment Data
  final List<CommentEntity> comments;
  // Per-comment "like busy" flag lock so user cant spam like
  final Map<String, bool> likeBusy;
  final String? activePostId;
  // errors
  final String? errorMessage;

  const CommentState({
    this.commentsLoading = false,
    this.actionLoading = false,
    this.comments = const [],
    this.likeBusy = const {},
    this.activePostId,
    this.errorMessage,
  });

  CommentState copyWith({
    bool? commentsLoading,
    bool? actionLoading,
    List<CommentEntity>? comments,
    Map<String, bool>? likeBusy,
    String? activePostId,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CommentState(
      commentsLoading: commentsLoading ?? this.commentsLoading,
      actionLoading: actionLoading ?? this.actionLoading,
      comments: comments ?? this.comments,
      likeBusy: likeBusy ?? this.likeBusy,
      activePostId: activePostId ?? this.activePostId,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    commentsLoading,
    actionLoading,
    comments,
    likeBusy,
    activePostId,
    errorMessage,
  ];
}
