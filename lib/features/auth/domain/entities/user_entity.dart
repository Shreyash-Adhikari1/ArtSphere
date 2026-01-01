import 'package:equatable/equatable.dart';

class UserEntity extends Equatable{
  final String? userId;
  final String fullName;
  final String email;
  final String? password;
  final String? phoneNumber;
  final String? address;

  UserEntity({
    this.userId,
    required this.fullName,
    required this.email,
    required this.password,
    this.address,
    this.phoneNumber
  });
  
  @override
  List<Object?> get props => [userId,fullName,email,password,address,phoneNumber];
}