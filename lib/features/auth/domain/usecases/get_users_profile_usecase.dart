import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/usecases/app_usecase.dart';
import 'package:artsphere/features/auth/data/repositories/user_repository.dart';
import 'package:artsphere/features/auth/domain/entities/user_entity.dart';
import 'package:artsphere/features/auth/domain/repositories/user_repositroy.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetUsersProfileUsecaseParams extends Equatable {
  final String userId;
  const GetUsersProfileUsecaseParams({required this.userId});
  @override
  List<Object?> get props => [userId];
}

final getUsersProfileUsecaseProvider = Provider<GetUsersProfileUsecase>((ref) {
  return GetUsersProfileUsecase(
    userRepository: ref.read(userRepositoryProvider),
  );
});

class GetUsersProfileUsecase
    implements UsecaseWithParams<UserEntity, GetUsersProfileUsecaseParams> {
  final IUserRepository _userRepository;
  GetUsersProfileUsecase({required IUserRepository userRepository})
    : _userRepository = userRepository;
  @override
  Future<Either<Failure, UserEntity>> call(
    GetUsersProfileUsecaseParams params,
  ) {
    return _userRepository.getUsersProfile(params.userId);
  }
}
