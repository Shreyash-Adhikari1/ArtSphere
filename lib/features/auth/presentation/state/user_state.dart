import 'package:artsphere/features/auth/domain/entities/user_entity.dart';
import 'package:equatable/equatable.dart';

enum UserStatus { initial,loading, authenticated, unauthenticated,registered, error }

class UserState extends Equatable {
  final UserStatus status;
  final UserEntity? userEntity;
  final String? errorMessage;

  const UserState({
    this.status=UserStatus.initial,
    this.userEntity,
    this.errorMessage,
  });

  UserState copyWith({
    UserStatus? status,
    UserEntity? userEntity,
    String? errorMessage
  }){
    return UserState(
      status: status ?? this.status,
      userEntity: userEntity ?? this.userEntity,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
  @override
  List<Object?> get props => [status, userEntity, errorMessage];
}
