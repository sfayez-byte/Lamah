import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/spacing.dart';
import 'package:flutter_application_1/widgets/text_field_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../main.dart';
import 'signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user == null || res.session == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed. Check credentials or email confirmation.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final user = res.user!;

      final existingProfileRes = await supabase
          .from('profiles')
          .select('*')
          .eq('id', user.id)
          .maybeSingle();

      if (existingProfileRes == null) {
        // Add updated_at during initial creation
        final List<Map<String, dynamic>> insertResponse = await supabase
    .from('profiles')
    .insert({
      'id': user.id,
      'email': user.email,
      'updated_at': DateTime.now().toIso8601String(),
    })
    .select();

if (insertResponse.isEmpty) { // ✅ Check if list is empty instead
  throw 'Insert to profiles failed: No data returned';
}
      }

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const BottomNavBar()),
        (route) => false,
      );

    } on AuthException catch (error) {
      String message = error.message;
      if (message.contains('Invalid login credentials')) {
        message = 'Invalid email or password';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );

    } catch (error, stack) {
      debugPrint('Unexpected login error: $error\n$stack');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unexpected error: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(backgroundColor: Colors.white),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Image.asset(
                'assets/logo1.png',
                width: 150,
                height: 100,
                fit: BoxFit.cover,
              ),
              height24,

              const Text(
                "Login",
                style: TextStyle(
                  fontSize: 24,
                  color: Color(0xFF2B3360),
                  fontWeight: FontWeight.bold,
                ),
              ),
              height24,

              TextFieldWidget(
                controller: _emailController,
                text: "Enter email",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.trim().endsWith('@gmail.com')) {
                    return 'Must be a @gmail.com address';
                  }
                  return null;
                },
              ),
              height24,

              TextFieldWidget(
                controller: _passwordController,
                text: "Enter password",
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 8) {
                    return 'Minimum 8 characters';
                  }
                  return null;
                },
              ),
              height12,

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const SignupPage()),
                    ),
                    child: const Text(
                      "Sign up",
                      style: TextStyle(
                        color: Color(0xFF2B3360),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              ElevatedButton(
                onPressed: _isLoading ? null : _signIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B3360),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 12,
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Login",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}