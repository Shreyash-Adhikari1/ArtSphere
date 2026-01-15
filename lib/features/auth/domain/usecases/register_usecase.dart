import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/usecases/app_usecase.dart';
import 'package:artsphere/features/auth/data/repositories/user_repository.dart';
import 'package:artsphere/features/auth/domain/entities/user_entity.dart';
import 'package:artsphere/features/auth/domain/repositories/user_repositroy.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterUsecaseParams extends Equatable {
  final String fullName;
  final String email;
  final String username;
  final String password;
  final String confirmPassword;
  final String? address;
  final String? phoneNumber;
  const RegisterUsecaseParams({
    required this.fullName,
    required this.email,
    required this.username,
    required this.password,
    required this.confirmPassword,
    this.address,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [fullName, email,username, password, address, phoneNumber];
}


// Provider for register usecase.
final registerUsecaseProvider = Provider<RegisterUsecase>((ref){
  return RegisterUsecase(userRepository: ref.read(userRepositoryProvider));
});



class RegisterUsecase implements UsecaseWithParams<bool, RegisterUsecaseParams> {
  final IUserRepositroy _userRepositroy;
  RegisterUsecase({required IUserRepositroy userRepository})
    : _userRepositroy = userRepository;

  @override
  Future<Either<Failure, bool>> call(RegisterUsecaseParams params) {
    final userEntity = UserEntity(
      fullName: params.fullName,
      username: params.username,
      email: params.email,
      password: params.password,
      confirmPassword: params.confirmPassword,
      address: params.address,
      phoneNumber: params.phoneNumber,
    );
    return _userRepositroy.registerUser(userEntity);
  }
}
