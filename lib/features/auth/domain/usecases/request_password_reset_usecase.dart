import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/usecases/app_usecase.dart';
import 'package:artsphere/features/auth/data/repositories/user_repository.dart';
import 'package:artsphere/features/auth/domain/repositories/user_repositroy.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RequestPasswordResetParams extends Equatable {
  final String email;
  const RequestPasswordResetParams({required this.email});

  @override
  List<Object?> get props => [email];
}

final requestPasswordResetUsecaseProvider =
    Provider<RequestPasswordResetUsecase>((ref) {
      return RequestPasswordResetUsecase(
        userRepository: ref.read(userRepositoryProvider),
      );
    });

class RequestPasswordResetUsecase
    implements UsecaseWithParams<String, RequestPasswordResetParams> {
  final IUserRepository _userRepository;
  RequestPasswordResetUsecase({required IUserRepository userRepository})
    : _userRepository = userRepository;

  @override
  Future<Either<Failure, String>> call(RequestPasswordResetParams params) {
    return _userRepository.requestPasswordReset(params.email);
  }
}
