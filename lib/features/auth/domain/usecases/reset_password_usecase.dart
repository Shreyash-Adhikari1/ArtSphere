import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/usecases/app_usecase.dart';
import 'package:artsphere/features/auth/data/repositories/user_repository.dart';
import 'package:artsphere/features/auth/domain/repositories/user_repositroy.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResetPasswordParams extends Equatable {
  final String token;
  final String newPassword;

  const ResetPasswordParams({required this.token, required this.newPassword});

  @override
  List<Object?> get props => [token, newPassword];
}

final resetPasswordUsecaseProvider = Provider<ResetPasswordUsecase>((ref) {
  return ResetPasswordUsecase(userRepository: ref.read(userRepositoryProvider));
});

class ResetPasswordUsecase
    implements UsecaseWithParams<bool, ResetPasswordParams> {
  final IUserRepository _userRepository;
  ResetPasswordUsecase({required IUserRepository userRepository})
    : _userRepository = userRepository;

  @override
  Future<Either<Failure, bool>> call(ResetPasswordParams params) {
    return _userRepository.resetPassword(
      token: params.token,
      newPassword: params.newPassword,
    );
  }
}
