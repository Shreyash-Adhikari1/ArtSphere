import 'package:freezed_annotation/freezed_annotation.dart';

part 'edit_challenge_api_model.g.dart';

@JsonSerializable(includeIfNull: false)
class EditChallengeApiModel {
  final String? challengeTitle;
  final String? challengeDescription;
  final DateTime? endsAt;
  const EditChallengeApiModel({
    this.challengeTitle,
    this.challengeDescription,
    this.endsAt,
  });

  factory EditChallengeApiModel.fromJson(Map<String, dynamic> json) =>
      _$EditChallengeApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$EditChallengeApiModelToJson(this);
}
