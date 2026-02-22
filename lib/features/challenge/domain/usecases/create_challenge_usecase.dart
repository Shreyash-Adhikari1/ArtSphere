import 'package:equatable/equatable.dart';

class CreateChallengeUsecaseParams extends Equatable {
  final String challengeTitle;
  final String challengeDescription;
  final String? challengeMedia;
  final DateTime endsAt;
  const CreateChallengeUsecaseParams({
    required this.challengeTitle,
    required this.challengeDescription,
    this.challengeMedia,
    required this.endsAt,
  });
  @override
  List<Object?> get props => [
    challengeTitle,
    challengeDescription,
    challengeMedia,
    endsAt,
  ];
}
