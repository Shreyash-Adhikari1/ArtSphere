import 'package:equatable/equatable.dart';

class UserEntity extends Equatable{
  final String? userId;
  final String fullName;
  final String username;
  final String email;
  final String? password;
  final String? confirmPassword;
  final String? phoneNumber;
  final String? address;

  const UserEntity({
    this.userId,
    required this.fullName,
    required this.username,
    required this.email,
    required this.password,
    required this.confirmPassword,
    this.address,
    this.phoneNumber
  });
  
  @override
  List<Object?> get props => [userId,fullName,username,email,password,address,phoneNumber];
}