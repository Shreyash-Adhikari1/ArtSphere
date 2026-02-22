import 'package:artsphere/features/auth/domain/entities/user_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'challenge_user_api_model.g.dart';

@JsonSerializable()
class ChallengeUserApiModel {
  @JsonKey(name: "_id")
  final String? id;

  final String? username;
  final String? avatar;
  const ChallengeUserApiModel({this.id, this.username, this.avatar});

  factory ChallengeUserApiModel.fromJson(Map<String, dynamic> json) =>
      _$ChallengeUserApiModelFromJson(json);
  Map<String, dynamic> toJson() => _$ChallengeUserApiModelToJson(this);

  // Convert to domain entity (preview user)
  UserEntity toEntity() {
    return UserEntity.preview(
      userId: id,
      username: username ?? "",
      avatar: avatar,
    );
  }

  // for when backend only gives id and not populated data
  factory ChallengeUserApiModel.fromId(String id) {
    return ChallengeUserApiModel(id: id);
  }
}
