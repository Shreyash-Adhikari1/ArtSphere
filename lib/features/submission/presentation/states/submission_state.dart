import 'package:artsphere/features/submission/domain/entities/submission_entity.dart';
import 'package:equatable/equatable.dart';

enum SubmissionStatus { initial, loading, success, failure }

enum SubmissionAction { none, submitExisting, createAndSubmit, delete }

class SubmissionState extends Equatable {
  // List state
  final SubmissionStatus status;
  final List<SubmissionEntity> submissions;
  final String? errorMessage;

  // Action state (submit/create/delete)
  final SubmissionStatus actionStatus;
  final SubmissionAction action;
  final String? actionErrorMessage;

  final String? deletingSubmissionId;
  final SubmissionEntity? lastActionResult;

  const SubmissionState({
    required this.status,
    required this.submissions,
    required this.actionStatus,
    required this.action,
    this.errorMessage,
    this.actionErrorMessage,
    this.deletingSubmissionId,
    this.lastActionResult,
  });

  const SubmissionState.initial()
    : status = SubmissionStatus.initial,
      submissions = const [],
      errorMessage = null,
      actionStatus = SubmissionStatus.initial,
      action = SubmissionAction.none,
      actionErrorMessage = null,
      deletingSubmissionId = null,
      lastActionResult = null;

  SubmissionState copyWith({
    SubmissionStatus? status,
    List<SubmissionEntity>? submissions,
    String? errorMessage,
    bool clearErrorMessage = false,

    SubmissionStatus? actionStatus,
    SubmissionAction? action,
    String? actionErrorMessage,
    bool clearActionErrorMessage = false,

    String? deletingSubmissionId,
    bool clearDeletingSubmissionId = false,

    SubmissionEntity? lastActionResult,
    bool clearLastActionResult = false,
  }) {
    return SubmissionState(
      status: status ?? this.status,
      submissions: submissions ?? this.submissions,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),

      actionStatus: actionStatus ?? this.actionStatus,
      action: action ?? this.action,
      actionErrorMessage: clearActionErrorMessage
          ? null
          : (actionErrorMessage ?? this.actionErrorMessage),

      deletingSubmissionId: clearDeletingSubmissionId
          ? null
          : (deletingSubmissionId ?? this.deletingSubmissionId),

      lastActionResult: clearLastActionResult
          ? null
          : (lastActionResult ?? this.lastActionResult),
    );
  }

  // Helpers
  bool get isLoading => status == SubmissionStatus.loading;
  bool get hasError =>
      status == SubmissionStatus.failure && errorMessage != null;

  bool get isActionLoading => actionStatus == SubmissionStatus.loading;
  bool get isActionSuccess => actionStatus == SubmissionStatus.success;
  bool get isActionFailure => actionStatus == SubmissionStatus.failure;

  @override
  List<Object?> get props => [
    status,
    submissions,
    errorMessage,
    actionStatus,
    action,
    actionErrorMessage,
    deletingSubmissionId,
    lastActionResult,
  ];
}
