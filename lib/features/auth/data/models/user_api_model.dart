import 'package:artsphere/features/auth/domain/entities/user_entity.dart';

class UserApiModel {
  final String? id;
  final String fullName;
  final String username;
  final String email;
  final String? password;
  final String? confirmPassword;
  final String? phoneNumber;
  final String? address;

  UserApiModel({
    this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.password,
    this.confirmPassword,
    this.phoneNumber,
    this.address,
  });

  // To JSON
  // Using dynamic because user le j pani value pathauna paayo
  Map<String, dynamic> toJson() {
    return {
      "fullName": fullName,
      "username": username,
      "email": email,
      "password": password,
      "confirmPassword":confirmPassword,
      "phoneNumber": phoneNumber,
      "address": address,
    };
  }

  // From JSON

  factory UserApiModel.fromJson(Map<String, dynamic> json) {
    return UserApiModel(
      id: json['_id'] as String,
      fullName: json['fullName'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      phoneNumber: json['phoneNumber'] as String,
      address: json['address'] as String,
    );
  }

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
    );
  }

  // To Entity List
  static List<UserEntity> toEntityList(List<UserApiModel> model) {
    return model.map((model) => model.toEntity()).toList();
  }
}
