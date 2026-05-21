import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';
import 'login_view.dart';
import 'books_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  SharedPreferences p = await SharedPreferences.getInstance();
  runApp(MyApp(isLoggedIn: p.getString('currentUser') != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(), // Pakai dark mode bawaan biar ga ribet set warna
      home: isLoggedIn ? const BooksView() : const LoginView(),
    );
  }
}