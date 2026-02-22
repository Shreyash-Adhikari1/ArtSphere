import 'package:artsphere/features/auth/domain/entities/user_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'follow_user_api_model.g.dart';

@JsonSerializable()
class FollowUserApiModel {
  @JsonKey(name: "_id")
  final String? id;

  final String? username;
  final String? avatar;
  const FollowUserApiModel({this.id, this.username, this.avatar});

  factory FollowUserApiModel.fromJson(Map<String, dynamic> json) =>
      _$FollowUserApiModelFromJson(json);
  Map<String, dynamic> toJson() => _$FollowUserApiModelToJson(this);

  // Convert to domain entity (preview user)
  UserEntity toEntity() {
    return UserEntity.preview(
      userId: id,
      username: username ?? "",
      avatar: avatar,
    );
  }

  // for when backend only gives id and not populated data
  factory FollowUserApiModel.fromId(String id) {
    return FollowUserApiModel(id: id);
  }
}
