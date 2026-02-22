import 'package:equatable/equatable.dart';

class EditChallengeUsecaseParams extends Equatable {
  final String challengeId;
  final String? challengeTitle;
  final String? challengeDescription;
  final DateTime? endsAt;
  const EditChallengeUsecaseParams({
    this.challengeTitle,
    this.challengeDescription,
    this.endsAt,
    required this.challengeId,
  });
  @override
  // TODO: implement props
  List<Object?> get props => [
    challengeId,
    challengeTitle,
    challengeDescription,
    endsAt,
  ];
}
