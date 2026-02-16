import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/usecases/app_usecase.dart';
import 'package:artsphere/features/auth/data/repositories/user_repository.dart';
import 'package:artsphere/features/auth/domain/repositories/user_repositroy.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// provider
final logoutUsecaseProvider = Provider<LogoutUsecase>((ref) {
  return LogoutUsecase(userRepository: ref.read(userRepositoryProvider));
});

class LogoutUsecase implements UsecaseWithoutParams<bool> {
  final IUserRepository _userRepository;
  LogoutUsecase({required IUserRepository userRepository})
    : _userRepository = userRepository;

  @override
  Future<Either<Failure, bool>> call() {
    return _userRepository.logout();
  }
}
