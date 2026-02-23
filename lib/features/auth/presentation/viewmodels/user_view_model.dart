import 'package:artsphere/core/services/biometrics/biometric_service.dart';
import 'package:artsphere/core/services/storage/biometric_pref_service.dart';
import 'package:artsphere/core/services/storage/token_service.dart';
import 'package:artsphere/features/auth/domain/usecases/edit_profile_usecase.dart';
import 'package:artsphere/features/auth/domain/usecases/get_profile_usecase.dart';
import 'package:artsphere/features/auth/domain/usecases/get_users_profile_usecase.dart';
import 'package:artsphere/features/auth/domain/usecases/login_usecase.dart';
import 'package:artsphere/features/auth/domain/usecases/logout_usecase.dart';
import 'package:artsphere/features/auth/domain/usecases/register_usecase.dart';
import 'package:artsphere/features/auth/domain/usecases/request_password_reset_usecase.dart';
import 'package:artsphere/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:artsphere/features/auth/presentation/state/user_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// user view model provider
final userViewModelProvider = NotifierProvider<UserViewModel, UserState>(
  () => UserViewModel(),
);

class UserViewModel extends Notifier<UserState> {
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;
  late final GetProfileUsecase _getProfileUsecase;
  late final EditProfileUsecase _editProfileUsecase;
  late final LogoutUsecase _logoutUsecase;
  late final GetUsersProfileUsecase _getUsersProfileUsecase;
  late final RequestPasswordResetUsecase _requestPasswordResetUsecase;
  late final ResetPasswordUsecase _resetPasswordUsecase;

  late final BiometricService _biometricService;
  late final BiometricPrefService _biometricPrefService;
  late final TokenService _tokenService;

  @override
  build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    _getProfileUsecase = ref.read(getProfileUsecaseProvider);
    _editProfileUsecase = ref.read(editProfileUsecaseProvider);
    _logoutUsecase = ref.read(logoutUsecaseProvider);
    _getUsersProfileUsecase = ref.read(getUsersProfileUsecaseProvider);
    _requestPasswordResetUsecase = ref.read(
      requestPasswordResetUsecaseProvider,
    );
    _resetPasswordUsecase = ref.read(resetPasswordUsecaseProvider);

    _biometricService = ref.read(biometricServiceProvider);
    _biometricPrefService = ref.read(biometricPrefServiceProvider);
    _tokenService = ref.read(tokenServiceProvider);

    Future.microtask(() async {
      await _initBiometrics();
      await getProfile(); // keep your existing behavior
    });
    return UserState();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void clearResetMessage() {
    state = state.copyWith(clearResetMessage: true);
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
    result.fold(
      (failure) {
        state = state.copyWith(
          status: UserStatus.error,
          errorMessage: failure.message,
        );
      },
      (isRegistered) {
        if (isRegistered) {
          state = state.copyWith(status: UserStatus.registered);
        } else {
          state = state.copyWith(
            status: UserStatus.error,
            errorMessage: "registration failed",
          );
        }
      },
    );
  }

  // Login Method
  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: UserStatus.loading);
    final loginParams = LoginUsecaseParams(email: email, password: password);
    final result = await _loginUsecase(loginParams);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: UserStatus.error,
          errorMessage: failure.message,
        );
      },
      (userEntity) {
        state = state.copyWith(
          status: UserStatus.authenticated,
          userEntity: userEntity,
        );
      },
    );
  }

  Future<void> logout() async {
    state = state.copyWith(status: UserStatus.loading);

    final result = await _logoutUsecase();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: UserStatus.error,
          errorMessage: failure.message,
        );
      },
      (ok) {
        if (ok) {
          // clear state in memory too
          state = state.copyWith(
            status: UserStatus.loggedOut,
            userEntity: null,
            errorMessage: null,
          );
        } else {
          state = state.copyWith(
            status: UserStatus.error,
            errorMessage: "Logout failed",
          );
        }
      },
    );
  }

  Future<void> getProfile() async {
    state = state.copyWith(status: UserStatus.loading);
    final result = await _getProfileUsecase();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: UserStatus.error,
          errorMessage: failure.message,
        );
      },
      (profile) {
        state = state.copyWith(status: UserStatus.success, userEntity: profile);
      },
    );
  }

  Future<void> getUsersProfile(String userId) async {
    state = state.copyWith(status: UserStatus.loading);
    final result = await _getUsersProfileUsecase(
      GetUsersProfileUsecaseParams(userId: userId),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: UserStatus.error,
          errorMessage: failure.message,
        );
      },
      (profile) {
        state = state.copyWith(
          status: UserStatus.success,
          viewingUserEntity: profile,
        );
      },
    );
  }

  // edit profile method
  Future<void> editProfile({
    String? fullName,
    String? username,
    String? avatar,
    String? address,
    String? phoneNumber,
  }) async {
    state = state.copyWith(status: UserStatus.loading);
    final editProfilerParams = EditProfileUsecaseParams(
      fullName: fullName,
      username: username,
      avatar: avatar,
      address: address,
      phoneNumber: phoneNumber,
    );
    final result = await _editProfileUsecase.call(editProfilerParams);
    await result.fold(
      (failure) {
        state = state.copyWith(
          status: UserStatus.error,
          errorMessage: failure.message,
        );
      },
      (isEdited) async {
        if (isEdited) {
          await getProfile();
          state = state.copyWith(status: UserStatus.edited);
        } else {
          state = state.copyWith(
            status: UserStatus.error,
            errorMessage: "edit profile failed",
          );
        }
      },
    );
  }

  Future<bool> requestPasswordReset(String email) async {
    state = state.copyWith(
      resetLoading: true,
      status: UserStatus.loading,
      clearError: true,
      clearResetMessage: true,
    );

    final result = await _requestPasswordResetUsecase(
      RequestPasswordResetParams(email: email),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          resetLoading: false,
          status: UserStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (msg) {
        state = state.copyWith(
          resetLoading: false,
          status: UserStatus.resetLinkSent,
          resetMessage: msg,
        );
        return true;
      },
    );
  }

  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    state = state.copyWith(
      resetLoading: true,
      status: UserStatus.loading,
      clearError: true,
      clearResetMessage: true,
    );

    final result = await _resetPasswordUsecase(
      ResetPasswordParams(token: token, newPassword: newPassword),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          resetLoading: false,
          status: UserStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (ok) {
        if (ok) {
          state = state.copyWith(
            resetLoading: false,
            status: UserStatus.passwordReset,
          );
          return true;
        } else {
          state = state.copyWith(
            resetLoading: false,
            status: UserStatus.error,
            errorMessage: "Password reset failed",
          );
          return false;
        }
      },
    );
  }

  Future<void> _initBiometrics() async {
    try {
      final available = await _biometricService.canCheck();
      final enabled = _biometricPrefService.isEnabled();

      state = state.copyWith(
        biometricAvailable: available,
        biometricEnabled: enabled,
      );
    } catch (_) {
      state = state.copyWith(
        biometricAvailable: false,
        biometricEnabled: false,
      );
    }
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    // If device can't do biometrics, don't allow enabling.
    if (!state.biometricAvailable && enabled) {
      state = state.copyWith(
        status: UserStatus.error,
        errorMessage: "Biometrics not available on this device",
      );
      return;
    }

    // Optional: require auth when enabling (feels pro)
    if (enabled) {
      final ok = await _biometricService.authenticate();
      if (!ok) {
        state = state.copyWith(
          status: UserStatus.error,
          errorMessage: "Fingerprint verification cancelled",
        );
        return;
      }
    }

    await _biometricPrefService.setEnabled(enabled);
    state = state.copyWith(biometricEnabled: enabled);
  }

  Future<bool> loginWithBiometrics() async {
    state = state.copyWith(biometricLoading: true, clearError: true);

    if (!state.biometricAvailable) {
      state = state.copyWith(
        biometricLoading: false,
        status: UserStatus.error,
        errorMessage: "Biometrics not available on this device",
      );
      return false;
    }

    if (!state.biometricEnabled) {
      state = state.copyWith(
        biometricLoading: false,
        status: UserStatus.error,
        errorMessage: "Enable biometric login in Profile settings first",
      );
      return false;
    }

    final ok = await _biometricService.authenticate();
    if (!ok) {
      state = state.copyWith(
        biometricLoading: false,
        status: UserStatus.error,
        errorMessage: "Fingerprint authentication failed",
      );
      return false;
    }

    // Must have token stored from previous login
    final token = await _tokenService.getToken();
    if (token == null || token.trim().isEmpty) {
      state = state.copyWith(
        biometricLoading: false,
        status: UserStatus.error,
        errorMessage: "No saved session. Please login with password once.",
      );
      return false;
    }

    // Use your existing profile call to validate token + fetch user
    final result = await _getProfileUsecase();

    return result.fold(
      (failure) {
        state = state.copyWith(
          biometricLoading: false,
          status: UserStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (profile) {
        state = state.copyWith(
          biometricLoading: false,
          status: UserStatus.authenticated,
          userEntity: profile,
        );
        return true;
      },
    );
  }
}
