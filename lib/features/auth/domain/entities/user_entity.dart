import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String? userId;
  final String fullName;
  final String username;
  final String email;
  final String? password;
  final String? confirmPassword;
  final String? phoneNumber;
  final String? address;
  final String? avatar;
  final int? followerCount;
  final int? followingCount;
  final int? postCount;
  final List<String>? posts;

  const UserEntity({
    this.userId,
    required this.fullName,
    required this.username,
    required this.email,
    required this.password,
    required this.confirmPassword,
    this.address,
    this.phoneNumber,
    this.avatar,
    this.followerCount,
    this.followingCount,
    this.postCount,
    this.posts,
  });

  /// i Added this olely for post, to get the author object that backend sends
  ///the required fields are filled with safe defaults.
  ///i did this to properly handle post logics api response as creation sends just the author:_id
  /// while other get operations send author:{_i, username , avatar}
  const UserEntity.preview({this.userId, required this.username, this.avatar})
    : fullName = "",
      email = "",
      password = "",
      confirmPassword = "",
      phoneNumber = null,
      address = null,
      followerCount = null,
      followingCount = null,
      postCount = null,
      posts = null;

  @override
  List<Object?> get props => [
    userId,
    fullName,
    username,
    email,
    password,
    address,
    phoneNumber,
    avatar,
    followerCount,
    followingCount,
    postCount,
    posts,
  ];
}
