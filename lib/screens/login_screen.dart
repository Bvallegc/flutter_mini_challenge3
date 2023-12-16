import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth.dart';
import 'package:provider/provider.dart';
import '../models/app_state_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/scheduler.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage;
  bool isLogin = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController  = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _confirmPasswordController  = TextEditingController();
  

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    );
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    return users
    .doc(userCredential.user?.uid)
    .set({
      'username': _usernameController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
    })
    .then((value) => print("Preferences Saved"))
    .catchError((error) => print("Failed to save preferences: $error"));
  } on FirebaseAuthException catch (e) {
  if (mounted) {
    setState(() {
      errorMessage = e.message;
    });
  }
  }
}

  Widget _textFieldEmail(
    String title,
    TextEditingController controller,
    ) {
    return TextField(
      controller: _emailController,
      decoration: const InputDecoration(
        labelText: 'Email',
      ),
    );
  }

  Widget _textFieldPassword(
    String title,
    TextEditingController controller,
    ) {
    return TextField(
      controller: _passwordController,
      decoration: const InputDecoration(
        labelText: 'Password',
      ),
    );
  }

  Widget _textFieldUsername(
    String title,
    TextEditingController controller,
    ) {
    return TextField(
      controller: _usernameController,
      decoration: const InputDecoration(
        labelText: 'Username',
      ),
    );
  }

  Widget _textFieldConfirmPassword(
    String title,
    TextEditingController controller,
    ) {
    return TextField(
      controller: _confirmPasswordController,
      decoration: const InputDecoration(
        labelText: 'Confirm Password',
      ),
    );
  }

  void _showError(String errorMessage) {
  SchedulerBinding.instance!.addPostFrameCallback((_) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$errorMessage'),
        backgroundColor: Colors.blue,
      ),
    );
  });
  }

  Widget _errorMessage() {
  if (errorMessage != null && errorMessage != '') {
    _showError(errorMessage!);
  }
  return Container();
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
          try {
            if (isLogin) {
              // Attempt to sign in
              await Auth().signInWithEmailAndPassword(
                email: _emailController.text,
                password: _passwordController.text,
              );
            } else {
             createUserWithEmailAndPassword();
            }
            Provider.of<AppStateManager>(context, listen: false)
                .login(_emailController.text, _passwordController.text);

        } on FirebaseAuthException catch (e) {
            setState(() {
              errorMessage = e.message;
            });
        }
      }
      },
      child: Text(isLogin ? 'Login' : 'Create Account'),
    );
  }

  Widget _loginOrRegisterButton(){
    return TextButton(
      onPressed: (){
        setState(() {
          isLogin = !isLogin;
        });
      },
      child: Text(isLogin ? 'Register instead' : 'Login instead'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    child: Icon(
                      Icons.movie,
                      size: 100,)
                  ),
                ),
              ),
              SizedBox(height: 20),
              _textFieldEmail('Email', _emailController),
              SizedBox(height: 20),
              _textFieldPassword('Password', _passwordController),
              SizedBox(height: 20),
              if (!isLogin) ...[
                _textFieldConfirmPassword('Confirm Password', _confirmPasswordController),
                SizedBox(height: 20),
                _textFieldUsername('Username', _usernameController),
              ],
              _errorMessage(),
              SizedBox(height: 20),
              _submitButton(),
              SizedBox(height: 20),
              _loginOrRegisterButton(),
            ],
          ),
        ),
      ),
    );
  }
}