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
  resetLinkSent,
  passwordReset,
  loggedOut,
}

class UserState extends Equatable {
  final UserStatus status;
  final UserEntity? userEntity;
  final UserEntity? viewingUserEntity;
  final bool resetLoading;
  final String? resetMessage;
  final String? errorMessage;

  const UserState({
    this.status = UserStatus.initial,
    this.userEntity,
    this.errorMessage,
    this.viewingUserEntity,
    this.resetLoading = false,
    this.resetMessage,
  });

  UserState copyWith({
    UserStatus? status,
    UserEntity? userEntity,
    UserEntity? viewingUserEntity,
    String? errorMessage,
    bool? resetLoading,
    String? resetMessage,
    bool clearResetMessage = false,
    bool clearError = false,
  }) {
    return UserState(
      status: status ?? this.status,
      userEntity: userEntity ?? this.userEntity,
      viewingUserEntity: viewingUserEntity ?? this.viewingUserEntity,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      resetLoading: resetLoading ?? this.resetLoading,
      resetMessage: clearResetMessage
          ? null
          : (resetMessage ?? this.resetMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    userEntity,
    viewingUserEntity,
    errorMessage,
    resetLoading,
    resetMessage,
  ];
}
