import 'package:flutter/material.dart';
import 'package:todolistapp/screen/auth/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:todolistapp/screen/todo.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _obscureText = true;
  bool isloding = false;
  GlobalKey<FormState> formkey = GlobalKey();
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
                                .createUserWithEmailAndPassword(
                                    email: emailController.text.trim(),
                                    password: passwordController.text.trim());
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Todo()),
                            );
                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'email-already-in-use') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('This email is already in use.'),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Registration failed. Please try again.')),
                              );
                            }
                          }
                          setState(() {
                            isloding = false;
                          });
                        } else {}
                      },
                      child: const Text('Create an account'),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Login()),
                        );
                      },
                      child: const Text(
                        "Back to login",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 20),
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
