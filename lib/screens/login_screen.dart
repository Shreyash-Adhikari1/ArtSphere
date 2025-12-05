import 'package:artsphere/screens/home_screen.dart';
import 'package:artsphere/screens/signup_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hiddenPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          height: double.infinity,
          width: double.infinity,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 50),
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2),
                    image: DecorationImage(
                      image: AssetImage('assets/images/artsphere_logo.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                SizedBox(height: 31),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Login",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 25),

                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(12),
                      child: Image.asset('assets/icons/email_icon.png'),
                    ),
                    label: Text(
                      'Email',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    hintText: 'Enter Your Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(67),
                    ),
                    filled: true,
                    fillColor: Color.fromARGB(44, 201, 116, 166),
                  ),
                  validator:(value) {
                    if (value == null || value.isEmpty){
                      return "Please enter your email";
                    }
                    return null;
                  },
                ),

                SizedBox(height: 31),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _hiddenPassword,

                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(12),
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
                    label: Text(
                      'Password',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    hintText: 'Enter Your Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(67),
                    ),
                    filled: true,
                    fillColor: Color.fromARGB(44, 201, 116, 166),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your password";
                    }
                    return null;
                  },
                ),

                SizedBox(height: 50),

                SizedBox(
                  height: 35,
                  width: 152,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFC974A6),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      if(_formKey.currentState!.validate()){ Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );}
                    },
                    child: Text("Login"),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "Forgot Your Password ?",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 122),

                Align(
                  alignment: Alignment.centerRight,
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(fontSize: 14, color: Color(0xFF7B7979)),
                      children: [
                        TextSpan(
                          text: "Sign Up !",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignupScreen(),
                                ),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
