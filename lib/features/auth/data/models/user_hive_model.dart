import 'package:artsphere/core/constants/hive_table_constant.dart';
import 'package:artsphere/features/auth/domain/entities/user_entity.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

part 'user_hive_model.g.dart';

// dart run build_runner build -d : CLI command to generate the adapter file
@HiveType(typeId: HiveTableConstant.userTypeId)
class UserHiveModel extends HiveObject {
  @HiveField(0)
  final String? userId;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? password;

  @HiveField(4)
  final String? confirmPassword;

  @HiveField(5)
  final String username;

  @HiveField(6)
  final String? phoneNumber;

  @HiveField(7)
  final String? address;

  UserHiveModel({
    String? userId,
    required this.fullName,
    required this.username,
    required this.email,
    required this.password,
    required this.confirmPassword,
    this.address,
    this.phoneNumber,
  }) : userId = userId ?? Uuid().v4();

  UserEntity toEntity() {
    return UserEntity(
      userId: userId,
      fullName: fullName,
      username: username,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      address: address,
      phoneNumber: phoneNumber,
    );
  }

  factory UserHiveModel.fromEntity(UserEntity entity) {
    return UserHiveModel(
      fullName: entity.fullName,
      username: entity.username,
      email: entity.email,
      password: entity.password,
      confirmPassword: entity.confirmPassword,
    );
  }

  static List<UserEntity> toEntityList(List<UserHiveModel> model) {
    return model.map((model) => model.toEntity()).toList();
  }
}
