import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'books_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;

  void _login() async {
    String user = _usernameController.text.trim();
    if (user.length < 5) {
      setState(() => _error = "Username minimal 5 karakter!");
      return;
    }
    if (_passwordController.text.trim() != "123230100") {
      setState(() => _error = "Password (NIM) salah!");
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentUser', user);
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const BooksView()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: _usernameController, decoration: InputDecoration(labelText: 'Username', errorText: _error)),
            const SizedBox(height: 10),
            TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password (NIM)')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: const Text('LOGIN')),
          ],
        ),
      ),
    );
  }
}