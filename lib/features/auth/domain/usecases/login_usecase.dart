import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/usecases/app_usecase.dart';
import 'package:artsphere/features/auth/data/repositories/user_repository.dart';
import 'package:artsphere/features/auth/domain/entities/user_entity.dart';
import 'package:artsphere/features/auth/domain/repositories/user_repositroy.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginUsecaseParams extends Equatable {
  final String email;
  final String password;
  const LoginUsecaseParams({
    required this.email,
    required this.password
  });

  @override
  List<Object?> get props =>[email, password];

}

// Provder For Login Usecase
final loginUsecaseProvider = Provider<LoginUsecase>((ref){
  return LoginUsecase(userRepository: ref.read(userRepositoryProvider));
});



class LoginUsecase implements UsecaseWithParams<UserEntity, LoginUsecaseParams>{
  final IUserRepositroy _userRepositroy;
  LoginUsecase({required IUserRepositroy userRepository})
    : _userRepositroy = userRepository;


  @override
  Future<Either<Failure, UserEntity>> call(LoginUsecaseParams params) {
    return _userRepositroy.loginUser(params.email, params.password);
  }
  
}