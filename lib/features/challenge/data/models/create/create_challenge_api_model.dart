import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_challenge_api_model.g.dart';

@JsonSerializable()
class CreateChallengeApiModel {
  final String challengeTitle;
  final String challengeDescription;
  final DateTime endsAt;
  const CreateChallengeApiModel({
    required this.challengeTitle,
    required this.challengeDescription,
    required this.endsAt,
  });

  factory CreateChallengeApiModel.fromJson(Map<String, dynamic> json) =>
      _$CreateChallengeApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$CreateChallengeApiModelToJson(this);
}
