import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/usecases/app_usecase.dart';
import 'package:artsphere/features/auth/data/repositories/user_repository.dart';
import 'package:artsphere/features/auth/domain/repositories/user_repositroy.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditProfileUsecaseParams extends Equatable {
  final String? fullName;
  final String? username;
  final String? address;
  final String? phoneNumber;
  final String? avatar;
  const EditProfileUsecaseParams({
    this.fullName,
    this.username,
    this.address,
    this.phoneNumber,
    this.avatar,
  });

  @override
  List<Object?> get props => [fullName, username, address, phoneNumber, avatar];
}

// provider
final editProfileUsecaseProvider = Provider<EditProfileUsecase>((ref) {
  return EditProfileUsecase(userRepository: ref.read(userRepositoryProvider));
});

class EditProfileUsecase
    implements UsecaseWithParams<bool, EditProfileUsecaseParams> {
  final IUserRepository _userRepository;
  EditProfileUsecase({required IUserRepository userRepository})
    : _userRepository = userRepository;
  @override
  Future<Either<Failure, bool>> call(EditProfileUsecaseParams params) {
    final user = EditProfileUsecaseParams(
      fullName: params.fullName,
      username: params.username,
      address: params.address,
      phoneNumber: params.phoneNumber,
      avatar: params.avatar,
    );

    return _userRepository.editProfile(user);
  }
}
