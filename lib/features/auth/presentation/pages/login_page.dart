import 'package:artsphere/app/routes/app_routes.dart';
import 'package:artsphere/core/utils/snackbar_utils.dart';
import 'package:artsphere/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:artsphere/features/auth/presentation/pages/home_screen.dart';
import 'package:artsphere/features/auth/presentation/pages/signup_page.dart';
import 'package:artsphere/features/auth/presentation/state/user_state.dart';
import 'package:artsphere/features/auth/presentation/viewmodels/user_view_model.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hiddenPassword = true;

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(userViewModelProvider.notifier)
          .login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    }
  }

  Future<void> _handleBiometricLogin() async {
    final ok = await ref
        .read(userViewModelProvider.notifier)
        .loginWithBiometrics();
    if (!mounted) return;

    if (ok) {
      // Keep navigation consistent with your existing listener behavior.
      AppRoutes.pushAndRemoveUntil(context, HomeScreen());
      SnackbarUtils.showSuccess(context, "Fingerprint Login SuccessFull");
    } else {
      final msg =
          ref.read(userViewModelProvider).errorMessage ??
          "Fingerprint login failed";
      SnackbarUtils.showError(context, msg);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Keep your existing listener logic intact
    ref.listen<UserState>(userViewModelProvider, (previous, next) {
      if (next.status == UserStatus.authenticated) {
        AppRoutes.pushAndRemoveUntil(context, HomeScreen());
        SnackbarUtils.showSuccess(context, "Login SuccessFull");
      } else if (next.status == UserStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage ?? "Login Failed");
      }
    });

    final userState = ref.watch(userViewModelProvider);

    final canUseBiometric =
        userState.biometricAvailable == true &&
        userState.biometricEnabled == true;
    final bioLoading = userState.biometricLoading == true;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxW = constraints.maxWidth;
            final maxH = constraints.maxHeight;

            // Responsive sizing
            final double logoSize = (maxW * 0.55).clamp(160.0, 250.0);
            final double contentMaxWidth = (maxW).clamp(0, 520).toDouble();

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentMaxWidth),
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: maxH * 0.03),

                        // Logo
                        Container(
                          width: logoSize,
                          height: logoSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 2),
                            image: const DecorationImage(
                              image: AssetImage(
                                'assets/images/artsphere_logo.png',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        SizedBox(height: maxH * 0.035),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        SizedBox(height: maxH * 0.03),

                        // Email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Image.asset('assets/icons/email_icon.png'),
                            ),
                            label: const Text(
                              'Email',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            hintText: 'Enter Your Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(67),
                            ),
                            filled: true,
                            fillColor: const Color.fromARGB(44, 201, 116, 166),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Please enter your email";
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: maxH * 0.03),

                        // Password
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _hiddenPassword,
                          decoration: InputDecoration(
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Image.asset(
                                'assets/icons/password_icon.png',
                                width: 20,
                                height: 20,
                              ),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _hiddenPassword = !_hiddenPassword;
                                });
                              },
                              icon: Image.asset('assets/icons/hidden_icon.png'),
                            ),
                            label: const Text(
                              'Password',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            hintText: 'Enter Your Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(67),
                            ),
                            filled: true,
                            fillColor: const Color.fromARGB(44, 201, 116, 166),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your password";
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: maxH * 0.03),

                        // Login button
                        SizedBox(
                          height: 42,
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC974A6),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _handleLogin,
                            child: const Text(
                              "Login",
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Fingerprint button (only show if device supports + enabled)
                        if (userState.biometricAvailable == true)
                          SizedBox(
                            height: 42,
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: (canUseBiometric && !bioLoading)
                                  ? _handleBiometricLogin
                                  : null,
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                side: const BorderSide(
                                  color: Color(0xFFC974A6),
                                ),
                              ),
                              icon: bioLoading
                                  ? const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.fingerprint,
                                      color: Color(0xFFC974A6),
                                    ),
                              label: Text(
                                canUseBiometric
                                    ? "Login with fingerprint"
                                    : "Enable fingerprint login in Profile",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFC974A6),
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 10),

                        TextButton(
                          onPressed: () {
                            AppRoutes.push(context, const ForgotPasswordPage());
                          },
                          child: const Text(
                            "Forgot Your Password ?",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        SizedBox(height: maxH * 0.05),

                        Align(
                          alignment: Alignment.centerRight,
                          child: RichText(
                            text: TextSpan(
                              text: "Don't have an account? ",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF7B7979),
                              ),
                              children: [
                                TextSpan(
                                  text: "Sign Up !",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      AppRoutes.push(
                                        context,
                                        const SignupScreen(),
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: maxH * 0.02),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
