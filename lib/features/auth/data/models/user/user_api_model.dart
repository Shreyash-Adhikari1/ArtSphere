import 'package:artsphere/features/auth/domain/entities/user_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_api_model.g.dart';

@JsonSerializable()
class UserApiModel {
  @JsonKey(name: "_id")
  final String? id;
  final String fullName;
  final String username;
  final String email;
  final String? password;
  final String? confirmPassword;
  final String? phoneNumber;
  final String? address;
  final String? avatar;
  final String? bio;
  final int? followerCount;
  final int? followingCount;
  final int? postCount;
  final List<String>? posts;

  UserApiModel({
    this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.password,
    this.confirmPassword,
    this.phoneNumber,
    this.address,
    this.avatar,
    this.bio,
    this.followerCount,
    this.followingCount,
    this.postCount,
    this.posts,
  });

  factory UserApiModel.fromJson(Map<String, dynamic> json) =>
      _$UserApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserApiModelToJson(this);

  // // To JSON
  // // Using dynamic because user le j pani value pathauna paayo
  // Map<String, dynamic> toJson() {
  //   return {
  //     "fullName": fullName,
  //     "username": username,
  //     "email": email,
  //     "password": password,
  //     "confirmPassword":confirmPassword,
  //     "phoneNumber": phoneNumber,
  //     "address": address,
  //   };
  // }

  // // From JSON

  // factory UserApiModel.fromJson(Map<String, dynamic> json) {
  //   final userJson = json['user'] ?? json;  // null safety measure. the code kept throwing it because some feilds were being returned null
  //   return UserApiModel(
  //     id: userJson['_id'] as String?,
  //     fullName: userJson['fullName'] as String? ?? '',
  //     username: userJson['username'] as String? ?? '',
  //     email: userJson['email'] as String? ?? '',
  //     password: userJson['password'] as String? ?? '',
  //     phoneNumber: userJson['phoneNumber'] as String? ?? '',
  //     address: userJson['address'] as String? ?? '',
  //   );
  // }

  // To Entity
  UserEntity toEntity() {
    return UserEntity(
      userId: id,
      fullName: fullName,
      username: username,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      address: address,
      phoneNumber: phoneNumber,
      avatar: avatar,
      bio: bio,
      followerCount: followerCount,
      followingCount: followingCount,
      postCount: postCount,
      posts: posts,
    );
  }

  // From Entity
  factory UserApiModel.fromEntity(UserEntity entity) {
    return UserApiModel(
      fullName: entity.fullName,
      username: entity.username,
      email: entity.email,
      password: entity.password,
      confirmPassword: entity.confirmPassword,
      phoneNumber: entity.phoneNumber,
      address: entity.address,
      avatar: entity.avatar,
      bio: entity.bio,
      followerCount: entity.followerCount,
      followingCount: entity.followingCount,
      postCount: entity.postCount,
      posts: entity.posts,
    );
  }

  // To Entity List
  static List<UserEntity> toEntityList(List<UserApiModel> model) {
    return model.map((model) => model.toEntity()).toList();
  }
}
