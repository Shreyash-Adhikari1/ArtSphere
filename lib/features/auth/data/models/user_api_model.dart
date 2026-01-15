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
    final userJson = json['user'] ?? json;  // null safety measure. the code kept throwing it because some feilds were being returned null
    return UserApiModel(
      id: userJson['_id'] as String?,
      fullName: userJson['fullName'] as String? ?? '',
      username: userJson['username'] as String? ?? '',
      email: userJson['email'] as String? ?? '',
      password: userJson['password'] as String? ?? '',
      phoneNumber: userJson['phoneNumber'] as String? ?? '',
      address: userJson['address'] as String? ?? '',
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
