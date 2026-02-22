import 'package:equatable/equatable.dart';

class EditChallengeUsecaseParams extends Equatable {
  final String? challengeTitle;
  final String? challengeDescription;
  final DateTime? endsAt;
  const EditChallengeUsecaseParams({
    this.challengeTitle,
    this.challengeDescription,
    this.endsAt,
  });
  @override
  // TODO: implement props
  List<Object?> get props => [challengeTitle, challengeDescription, endsAt];
}
