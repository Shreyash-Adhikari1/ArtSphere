import 'package:artsphere/screens/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _hiddenPassword = true ;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 50),
                        Container(
                          width: 210,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 2),
                            image: DecorationImage(
                              image: AssetImage('assets/images/artsphere_logo.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
              
                        SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Signup",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: 15),
              
                        TextFormField(
                          controller: _fullNameController,
                          decoration: InputDecoration(
                            prefixIcon: Padding(
                              padding: EdgeInsets.all(12),
                              child: Image.asset('assets/icons/profile_icon.png'),
                            ),
                            label: Text(
                              'Full Name',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            hintText: 'Enter Your Full Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(67),
                            ),
                            filled: true,
                            fillColor: Color.fromARGB(44, 201, 116, 166),
                          ),
                        ),
                        
                        SizedBox(height: 15),
              
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
                        ),
              
                        SizedBox(height: 15),
              
                        TextFormField(
                          controller: _phoneNumberController,
                          decoration: InputDecoration(
                            prefixIcon: Padding(
                              padding: EdgeInsets.all(12),
                              child: Image.asset('assets/icons/phone_icon.png'),
                            ),
                            label: Text(
                              'Phone Number',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            hintText: 'Enter Your Contact Number',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(67),
                            ),
                            filled: true,
                            fillColor: Color.fromARGB(44, 201, 116, 166),
                          ),
                        ),
                        SizedBox(height: 15),
              
                        TextFormField(
                          controller: _addressController,
                          decoration: InputDecoration(
                            prefixIcon: Padding(
                              padding: EdgeInsets.all(12),
                              child: Image.asset('assets/icons/address_icon.png'),
                            ),
                            label: Text(
                              'Address',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            hintText: 'Enter Your Address',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(67),
                            ),
                            filled: true,
                            fillColor: Color.fromARGB(44, 201, 116, 166),
                          ),
                        ),
              
                        SizedBox(height: 15),
              
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
                        ),
              
                        SizedBox(height: 15),
                        TextFormField(
                          controller: _confirmPasswordController,
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
                              'Confirm Password',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            hintText: 'Enter Your Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(67),
                            ),
                            filled: true,
                            fillColor: Color.fromARGB(44, 201, 116, 166),
                          ),
                        ),
                        SizedBox(height: 44),
              
                        SizedBox(
                          height: 35,
                          width: 152,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFC974A6),
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            child: Text("Signup"),
                          ),
                        ),
              
                        SizedBox(height: 30),
                        Align(
                          alignment: Alignment.centerRight,
                          child: RichText(
                            text: TextSpan(
                              text: "Already Registered? ",
                              style: TextStyle(fontSize: 14, color: Color(0xFF7B7979)),
                              children: [
                                TextSpan(
                                  text: "Login !",
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
                                          builder: (context) => const LoginScreen(),
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
            ),
          ),
        ),
      ),
    );
  }
}