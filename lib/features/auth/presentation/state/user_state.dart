import 'package:artsphere/features/auth/domain/entities/user_entity.dart';
import 'package:equatable/equatable.dart';

enum UserStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  registered,
  edited,
  error,
  success,
  loggedOut,
}

class UserState extends Equatable {
  final UserStatus status;
  final UserEntity? userEntity;
  final UserEntity? viewingUserEntity;
  final String? errorMessage;

  const UserState({
    this.status = UserStatus.initial,
    this.userEntity,
    this.errorMessage,
    this.viewingUserEntity,
  });

  UserState copyWith({
    UserStatus? status,
    UserEntity? userEntity,
    UserEntity? viewingUserEntity,
    String? errorMessage,
  }) {
    return UserState(
      status: status ?? this.status,
      userEntity: userEntity ?? this.userEntity,
      viewingUserEntity: viewingUserEntity ?? this.viewingUserEntity,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    userEntity,
    viewingUserEntity,
    errorMessage,
  ];
}
