import 'package:artsphere/features/auth/domain/entities/user_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// This file has been made to handle the author object we get from the backend api
// this one only returns author._id, author.username and author.avatar,
// basically what all getpost operations send
part 'post_author_api_model.g.dart';

@JsonSerializable()
class PostAuthorApiModel {
  @JsonKey(name: "_id")
  final String? id;

  final String? username;
  final String? avatar;

  const PostAuthorApiModel({this.id, this.username, this.avatar});

  factory PostAuthorApiModel.fromJson(Map<String, dynamic> json) =>
      _$PostAuthorApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$PostAuthorApiModelToJson(this);

  /// Convert to domain entity (preview user)
  UserEntity toEntity() {
    return UserEntity.preview(
      userId: id,
      username: username ?? "",
      avatar: avatar,
    );
  }

  /// When backend gives only authorId (string)
  factory PostAuthorApiModel.fromId(String id) {
    return PostAuthorApiModel(id: id);
  }
}
