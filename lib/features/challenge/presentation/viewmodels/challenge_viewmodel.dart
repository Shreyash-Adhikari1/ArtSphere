import 'package:artsphere/features/challenge/domain/entities/challenge_entity.dart';
import 'package:artsphere/features/challenge/domain/usecases/create_challenge_usecase.dart';
import 'package:artsphere/features/challenge/domain/usecases/delete_challenge_usecase.dart';
import 'package:artsphere/features/challenge/domain/usecases/edit_challenge_usecase.dart';
import 'package:artsphere/features/challenge/domain/usecases/get_all_challenges_usecase.dart';
import 'package:artsphere/features/challenge/domain/usecases/get_challenge_by_id_usecase.dart';
import 'package:artsphere/features/challenge/domain/usecases/get_my_challenges_usecase.dart';
import 'package:artsphere/features/challenge/presentation/states/challenge_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final challengeViewModelProvider =
    NotifierProvider<ChallengeViewModel, ChallengeState>(
      () => ChallengeViewModel(),
    );

class ChallengeViewModel extends Notifier<ChallengeState> {
  late final CreateChallengeUsecase _create;
  late final EditChallengeUsecase _edit;
  late final DeleteChallengeUsecase _delete;

  late final GetAllChallengesUsecase _getAll;
  late final GetMyChallengesUsecase _getMine;
  late final GetChallengeByIdUsecase _getById;

  @override
  ChallengeState build() {
    _create = ref.read(createChallengeUsecaseProvider);
    _edit = ref.read(editChallengeUsecaseProvider);
    _delete = ref.read(deleteChallengeUsecaseProvider);

    _getAll = ref.read(getAllChallengesUsecaseProvider);
    _getMine = ref.read(getMyChallengesUsecaseProvider);
    _getById = ref.read(getChallengeByIdUsecaseProvider);

    return const ChallengeState();
  }

  void clearError() => state = state.copyWith(clearError: true);

  bool _isBusy(String id) => state.busyById[id] == true;

  void _setBusy(String id, bool busy) {
    state = state.copyWith(busyById: {...state.busyById, id: busy});
  }

  // -------- loaders --------

  Future<void> loadDiscoverChallenges() async {
    state = state.copyWith(discoverLoading: true, clearError: true);

    final result = await _getAll();
    result.fold(
      (f) => state = state.copyWith(
        discoverLoading: false,
        errorMessage: f.message,
      ),
      (items) => state = state.copyWith(
        discoverLoading: false,
        discoverChallenges: items,
      ),
    );
  }

  Future<void> loadMyChallenges() async {
    state = state.copyWith(myChallengesLoading: true, clearError: true);

    final result = await _getMine();
    result.fold(
      (f) => state = state.copyWith(
        myChallengesLoading: false,
        errorMessage: f.message,
      ),
      (items) => state = state.copyWith(
        myChallengesLoading: false,
        myChallenges: items,
      ),
    );
  }

  Future<void> loadChallengeDetails(String challengeId) async {
    if (challengeId.trim().isEmpty) return;
    state = state.copyWith(detailsLoading: true, clearError: true);

    final result = await _getById(
      GetChallengeByIdUsecaseParams(challengeId: challengeId),
    );
    result.fold(
      (f) => state = state.copyWith(
        detailsLoading: false,
        errorMessage: f.message,
      ),
      (challenge) => state = state.copyWith(
        detailsLoading: false,
        activeChallenge: challenge,
      ),
    );
  }

  // -------- actions --------

  Future<ChallengeEntity?> createChallenge(
    CreateChallengeUsecaseParams params,
  ) async {
    state = state.copyWith(actionLoading: true, clearError: true);

    final result = await _create(params);

    return result.fold(
      (f) {
        state = state.copyWith(actionLoading: false, errorMessage: f.message);
        return null;
      },
      (created) {
        // optimistic insert in lists
        state = state.copyWith(
          actionLoading: false,
          discoverChallenges: [created, ...state.discoverChallenges],
          myChallenges: [created, ...state.myChallenges],
        );
        return created;
      },
    );
  }

  Future<ChallengeEntity?> editChallenge(
    EditChallengeUsecaseParams params,
  ) async {
    if (params.challengeId.trim().isEmpty) {
      state = state.copyWith(errorMessage: "ChallengeId is required");
      return null;
    }

    state = state.copyWith(actionLoading: true, clearError: true);

    final result = await _edit(params);

    return result.fold(
      (f) {
        state = state.copyWith(actionLoading: false, errorMessage: f.message);
        return null;
      },
      (updated) {
        List<ChallengeEntity> replace(List<ChallengeEntity> list) {
          return list
              .map((c) => (c.challengeId == updated.challengeId) ? updated : c)
              .toList();
        }

        state = state.copyWith(
          actionLoading: false,
          discoverChallenges: replace(state.discoverChallenges),
          myChallenges: replace(state.myChallenges),
          activeChallenge:
              state.activeChallenge?.challengeId == updated.challengeId
              ? updated
              : state.activeChallenge,
        );

        return updated;
      },
    );
  }

  Future<bool> deleteChallenge(String challengeId) async {
    if (challengeId.trim().isEmpty) return false;
    if (_isBusy(challengeId)) return false;

    _setBusy(challengeId, true);
    clearError();

    // optimistic remove
    final oldDiscover = state.discoverChallenges;
    final oldMine = state.myChallenges;

    state = state.copyWith(
      discoverChallenges: oldDiscover
          .where((c) => c.challengeId != challengeId)
          .toList(),
      myChallenges: oldMine.where((c) => c.challengeId != challengeId).toList(),
    );

    final result = await _delete(
      DeleteChallengeUsecaseParams(challengeId: challengeId),
    );

    final ok = result.fold((f) {
      // rollback
      state = state.copyWith(
        discoverChallenges: oldDiscover,
        myChallenges: oldMine,
        errorMessage: f.message,
      );
      return false;
    }, (success) => success);

    _setBusy(challengeId, false);
    return ok;
  }
}
