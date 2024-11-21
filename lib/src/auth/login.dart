import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gigacharge/src/gigachargeapp.dart';

import 'register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _loggingIn = false;
  bool _obscurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() async {
    FocusScope.of(context).unfocus();
    setState(() => _loggingIn = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const GigaSwapApp()),
      );
    } catch (e) {
      setState(() => _loggingIn = false);
      _showErrorDialog(e.toString());
    }
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F7FF),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        //title: const Text('Login'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Welcome Back!',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Login to continue',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: const Color(0xff666666),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                enabled: !_loggingIn,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelStyle: const TextStyle(color: Color(0xff5486ed)),
                  labelText: 'Email Address',
                  hintText: 'Enter your email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xff5486ed)),
                  ),
                  //prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                enabled: !_loggingIn,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelStyle: const TextStyle(color: Color(0xff5486ed)),
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xff5486ed)),
                  ),
                  //prefixIcon: const Icon(Icons.lock),
                  // suffixIcon: IconButton(
                  //   icon: const Icon(Icons.visibility),
                  //   onPressed: () {}, // Add toggle visibility logic here
                  // ),
                ),
                obscureText: _obscurePassword, //set this to true if you want to have keyboard pop up or smth
                textInputAction: TextInputAction.done,
                onEditingComplete: _login,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loggingIn ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff5486ed),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _loggingIn
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Login',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: _loggingIn
                    ? null
                    : () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const RegisterPage(),
                    ),
                  );
                },
                child: const Text(
                  'Don\'t have an account? Register',
                  style: TextStyle(
                    color: Color(0xff5486ed),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
