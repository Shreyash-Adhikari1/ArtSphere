import 'package:artsphere/features/challenge/domain/entities/challenge_entity.dart';
import 'package:equatable/equatable.dart';

class ChallengeState extends Equatable {
  final bool discoverLoading;
  final bool myChallengesLoading;
  final bool detailsLoading;
  final bool actionLoading;

  final List<ChallengeEntity> discoverChallenges;
  final List<ChallengeEntity> myChallenges;

  final ChallengeEntity? activeChallenge;

  // per-challenge action lock (delete/edit/submit etc.)
  final Map<String, bool> busyById;

  final String? errorMessage;

  const ChallengeState({
    this.discoverLoading = false,
    this.myChallengesLoading = false,
    this.detailsLoading = false,
    this.actionLoading = false,
    this.discoverChallenges = const [],
    this.myChallenges = const [],
    this.activeChallenge,
    this.busyById = const {},
    this.errorMessage,
  });

  ChallengeState copyWith({
    bool? discoverLoading,
    bool? myChallengesLoading,
    bool? detailsLoading,
    bool? actionLoading,
    List<ChallengeEntity>? discoverChallenges,
    List<ChallengeEntity>? myChallenges,
    ChallengeEntity? activeChallenge,
    Map<String, bool>? busyById,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ChallengeState(
      discoverLoading: discoverLoading ?? this.discoverLoading,
      myChallengesLoading: myChallengesLoading ?? this.myChallengesLoading,
      detailsLoading: detailsLoading ?? this.detailsLoading,
      actionLoading: actionLoading ?? this.actionLoading,
      discoverChallenges: discoverChallenges ?? this.discoverChallenges,
      myChallenges: myChallenges ?? this.myChallenges,
      activeChallenge: activeChallenge ?? this.activeChallenge,
      busyById: busyById ?? this.busyById,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    discoverLoading,
    myChallengesLoading,
    detailsLoading,
    actionLoading,
    discoverChallenges,
    myChallenges,
    activeChallenge,
    busyById,
    errorMessage,
  ];
}
