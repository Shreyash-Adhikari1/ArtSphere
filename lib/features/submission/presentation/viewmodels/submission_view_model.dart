import 'package:artsphere/features/post/domain/entities/post_entity.dart';
import 'package:artsphere/features/submission/domain/entities/submission_entity.dart';
import 'package:artsphere/features/submission/domain/usecases/create_new_post_and_submit_usecase.dart';
import 'package:artsphere/features/submission/domain/usecases/delete_submission_usecase.dart';
import 'package:artsphere/features/submission/domain/usecases/get_submissions_for_challenge_usecase.dart';
import 'package:artsphere/features/submission/domain/usecases/submit_existing_post_usecase.dart';
import 'package:artsphere/features/submission/presentation/states/submission_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final submissionViewModelProvider =
    NotifierProvider<SubmissionViewModel, SubmissionState>(
      () => SubmissionViewModel(),
    );

class SubmissionViewModel extends Notifier<SubmissionState> {
  late final GetSubmissionsForChallengeUsecase _getForChallenge;
  late final SubmitExistingPostUsecase _submitExisting;
  late final CreateNewPostAndSubmitUsecase _createAndSubmit;
  late final DeleteSubmissionUsecase _delete;

  String? _activeChallengeId;

  @override
  SubmissionState build() {
    _getForChallenge = ref.read(getSubmissionsForChallengeUsecaseProvider);
    _submitExisting = ref.read(submitExistingPostUsecaseProvider);
    _createAndSubmit = ref.read(createNewPostAndSubmitUsecaseProvider);
    _delete = ref.read(deleteSubmissionUsecaseProvider);

    return const SubmissionState.initial();
  }

  // ---- helpers (challenge vm style) ----

  void clearError() {
    state = state.copyWith(clearErrorMessage: true);
  }

  void clearActionState() {
    state = state.copyWith(
      actionStatus: SubmissionStatus.initial,
      action: SubmissionAction.none,
      clearActionErrorMessage: true,
      clearLastActionResult: true,
      clearDeletingSubmissionId: true,
    );
  }

  bool _isBusy(String submissionId) =>
      state.deletingSubmissionId == submissionId;

  // ---- loaders ----

  Future<void> loadSubmissions(String challengeId) async {
    if (challengeId.trim().isEmpty) return;

    _activeChallengeId = challengeId;
    state = state.copyWith(
      status: SubmissionStatus.loading,
      clearErrorMessage: true,
    );

    final result = await _getForChallenge(
      GetSubmissionsForChallengeUsecaseParams(challengeId: challengeId),
    );

    result.fold(
      (f) => state = state.copyWith(
        status: SubmissionStatus.failure,
        errorMessage: f.message,
      ),
      (items) => state = state.copyWith(
        status: SubmissionStatus.success,
        submissions: items,
        clearErrorMessage: true,
      ),
    );
  }

  Future<void> refresh() async {
    final id = _activeChallengeId;
    if (id == null) return;
    // keep UI list visible, just refresh silently
    final result = await _getForChallenge(
      GetSubmissionsForChallengeUsecaseParams(challengeId: id),
    );
    result.fold((_) {}, (items) => state = state.copyWith(submissions: items));
  }

  // ---- actions ----

  Future<SubmissionEntity?> submitExistingPost({
    required String challengeId,
    required String postId,
  }) async {
    if (challengeId.trim().isEmpty || postId.trim().isEmpty) return null;

    _activeChallengeId = challengeId;

    state = state.copyWith(
      actionStatus: SubmissionStatus.loading,
      action: SubmissionAction.submitExisting,
      clearActionErrorMessage: true,
      clearLastActionResult: true,
    );

    final result = await _submitExisting(
      SubmitExistingPostUsecaseParams(challengeId: challengeId, postId: postId),
    );

    return result.fold(
      (f) {
        state = state.copyWith(
          actionStatus: SubmissionStatus.failure,
          actionErrorMessage: f.message,
        );
        return null;
      },
      (created) async {
        state = state.copyWith(
          actionStatus: SubmissionStatus.success,
          lastActionResult: created,
          clearActionErrorMessage: true,
        );

        // refresh list (submission create response may not be fully populated)
        await refresh();
        return created;
      },
    );
  }

  Future<SubmissionEntity?> createNewPostAndSubmit({
    required String challengeId,
    required PostEntity post,
    required String mediaPath,
  }) async {
    if (challengeId.trim().isEmpty || mediaPath.trim().isEmpty) return null;

    _activeChallengeId = challengeId;

    state = state.copyWith(
      actionStatus: SubmissionStatus.loading,
      action: SubmissionAction.createAndSubmit,
      clearActionErrorMessage: true,
      clearLastActionResult: true,
    );

    final result = await _createAndSubmit(
      CreateNewPostAndSubmitUsecaseParams(
        challengeId: challengeId,
        post: post,
        mediaPath: mediaPath,
      ),
    );

    return result.fold(
      (f) {
        state = state.copyWith(
          actionStatus: SubmissionStatus.failure,
          actionErrorMessage: f.message,
        );
        return null;
      },
      (created) async {
        state = state.copyWith(
          actionStatus: SubmissionStatus.success,
          lastActionResult: created,
          clearActionErrorMessage: true,
        );

        await refresh();
        return created;
      },
    );
  }

  Future<bool> deleteSubmission(String submissionId) async {
    if (submissionId.trim().isEmpty) return false;
    if (_isBusy(submissionId)) return false;

    // optimistic remove (same as challenge delete)
    final oldList = state.submissions;
    state = state.copyWith(
      submissions: oldList
          .where((s) => s.submissionId != submissionId)
          .toList(),
      deletingSubmissionId: submissionId,
      actionStatus: SubmissionStatus.loading,
      action: SubmissionAction.delete,
      clearActionErrorMessage: true,
      clearLastActionResult: true,
    );

    final result = await _delete(
      DeleteSubmissionUsecaseParams(submissionId: submissionId),
    );

    final ok = result.fold(
      (f) {
        // rollback
        state = state.copyWith(
          submissions: oldList,
          actionStatus: SubmissionStatus.failure,
          actionErrorMessage: f.message,
          clearDeletingSubmissionId: true,
        );
        return false;
      },
      (success) {
        state = state.copyWith(
          actionStatus: SubmissionStatus.success,
          clearActionErrorMessage: true,
          clearDeletingSubmissionId: true,
        );
        return success;
      },
    );

    return ok;
  }
}
