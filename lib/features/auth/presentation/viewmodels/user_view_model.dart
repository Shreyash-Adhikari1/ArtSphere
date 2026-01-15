import 'package:artsphere/features/auth/domain/usecases/login_usecase.dart';
import 'package:artsphere/features/auth/domain/usecases/register_usecase.dart';
import 'package:artsphere/features/auth/presentation/state/user_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// user view model provider
final userViewModelProvider= NotifierProvider<UserViewModel, UserState>(
  ()=>UserViewModel()
);

class UserViewModel extends Notifier<UserState> {
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;

  @override
  build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    return UserState();
  }
  // register method 
  Future<void> register({
    required String fullName,
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    String? address,
    String? phoneNumber,
  }) async {
    state = state.copyWith(status: UserStatus.loading);
    final registerParams = RegisterUsecaseParams(
      fullName: fullName,
      email: email,
      username: username,
      password: password,
      confirmPassword: confirmPassword,
      address: address,
      phoneNumber: phoneNumber,
    );
    final result = await _registerUsecase.call(registerParams);
    result.fold((failure){
      state=state.copyWith(
        status: UserStatus.error,
        errorMessage: failure.message
      );
    },(isRegistered){
      if (isRegistered) {
        state=state.copyWith(status: UserStatus.registered);
      }else{
        state=state.copyWith(
        status: UserStatus.error,
        errorMessage: "registration failed"
      );
      }
      
    });
  }


  // Login Method
  Future<void> login({
    required String email,
    required String password
  })async{
    state=state.copyWith(status: UserStatus.loading);
    final loginParams=LoginUsecaseParams(email: email, password: password);
    final result= await _loginUsecase(loginParams);

    result.fold((failure){
      state=state.copyWith(
        status: UserStatus.error,
        errorMessage: failure.message
      );
    }, 
    (userEntity){
      state=state.copyWith(
        status: UserStatus.authenticated,
        userEntity: userEntity,
      );
    });
  }
}
