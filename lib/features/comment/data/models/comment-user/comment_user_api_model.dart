import 'package:artsphere/features/auth/domain/entities/user_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment_user_api_model.g.dart';

@JsonSerializable()
class CommentUserApiModel {
  @JsonKey(name: "_id")
  final String? id;

  final String? username;
  final String? avatar;
  const CommentUserApiModel({this.id, this.username, this.avatar});

  factory CommentUserApiModel.fromJson(Map<String, dynamic> json) =>
      _$CommentUserApiModelFromJson(json);
  Map<String, dynamic> toJson() => _$CommentUserApiModelToJson(this);

  // Convert to domain entity (preview user)
  UserEntity toEntity() {
    return UserEntity.preview(
      userId: id,
      username: username ?? "",
      avatar: avatar,
    );
  }

  // for when backend only gives id and not populated data
  factory CommentUserApiModel.fromId(String id) {
    return CommentUserApiModel(id: id);
  }
}
