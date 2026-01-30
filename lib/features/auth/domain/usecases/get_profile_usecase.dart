import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/usecases/app_usecase.dart';
import 'package:artsphere/features/auth/data/repositories/user_repository.dart';
import 'package:artsphere/features/auth/domain/entities/user_entity.dart';
import 'package:artsphere/features/auth/domain/repositories/user_repositroy.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getProfileUsecaseProvider = Provider<GetProfileUsecase>((ref) {
  return GetProfileUsecase(userRepository: ref.read(userRepositoryProvider));
});

class GetProfileUsecase implements UsecaseWithoutParams<UserEntity> {
  final IUserRepository _userRepository;
  GetProfileUsecase({required IUserRepository userRepository})
    : _userRepository = userRepository;
  @override
  Future<Either<Failure, UserEntity>> call() {
    return _userRepository.getProfile();
  }
}
