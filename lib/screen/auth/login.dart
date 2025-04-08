import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:todolistapp/screen/auth/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todolistapp/screen/auth/reset_password.dart';
import 'package:todolistapp/screen/todo.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool _obscureText = true;
  bool isloding = false;
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isloding,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formkey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: SizedBox(
                        height: 350,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Image.asset(
                            'images/to_do.jpg',
                          ),
                        ),
                      ),
                    ),
                    TextFormField(
                      validator: (data) {
                        if (data == null || data.isEmpty) {
                          return "Required field";
                        }
                        return null;
                      },
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter your email',
                      ),
                    ),
                    const SizedBox(height: 40),
                    TextFormField(
                      validator: (data) {
                        if (data == null || data.isEmpty) {
                          return "Required field";
                        }
                        return null;
                      },
                      controller: passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: 'Enter your password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () async {
                        if (formkey.currentState!.validate()) {
                          setState(() {
                            isloding = true;
                          });
                          try {
                            UserCredential user = await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                              email: emailController.text.trim(),
                              password: passwordController.text.trim(),
                            );

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Todo()),
                            );
                          } on FirebaseAuthException catch (e) {
                            String message;
                            if (e.code == 'user-not-found') {
                              message = 'No user found for that email.';
                            } else if (e.code == 'wrong-password') {
                              message = 'Wrong password provided.';
                            } else {
                              message = 'Login failed. Please try again.';
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(message)),
                            );
                          }
                          setState(() {
                            isloding = false;
                          });
                        }
                      },
                      child: const Text('Login'),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Register()),
                        );
                      },
                      child: const Text(
                        "Create an account",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ResetPassword()),
                        );
                      },
                      child: const Text(
                        "Reset your password",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
