// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserApiModel _$UserApiModelFromJson(Map<String, dynamic> json) => UserApiModel(
      id: json['_id'] as String?,
      fullName: json['fullName'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      password: json['password'] as String?,
      confirmPassword: json['confirmPassword'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      address: json['address'] as String?,
      avatar: json['avatar'] as String?,
      followerCount: (json['followerCount'] as num?)?.toInt(),
      followingCount: (json['followingCount'] as num?)?.toInt(),
      postCount: (json['postCount'] as num?)?.toInt(),
      posts:
          (json['posts'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$UserApiModelToJson(UserApiModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'fullName': instance.fullName,
      'username': instance.username,
      'email': instance.email,
      'password': instance.password,
      'confirmPassword': instance.confirmPassword,
      'phoneNumber': instance.phoneNumber,
      'address': instance.address,
      'avatar': instance.avatar,
      'followerCount': instance.followerCount,
      'followingCount': instance.followingCount,
      'postCount': instance.postCount,
      'posts': instance.posts,
    };
