import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});
  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  String _username = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  _load() async {
    SharedPreferences p = await SharedPreferences.getInstance();
    setState(() => _username = p.getString('currentUser') ?? 'User');
  }

  @override
  Widget build(BuildContext context) {
    String char = _username.isNotEmpty ? _username[0].toUpperCase() : '?';
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(radius: 40, child: Text(char, style: const TextStyle(fontSize: 32))),
            ),
            const SizedBox(height: 10),
            Center(child: Text("Username: $_username", style: const TextStyle(fontSize: 18))),
            const Divider(),
            const Text("Kesan:", style: TextStyle(fontWeight: FontWeight.bold)),
            const Text("Praktikum TPM ini memberikan banyak insight baru mengenai integrasi API, manajemen session, dan penyimpanan lokal secara nyata."),
            const SizedBox(height: 10),
            const Text("Pesan:", style: TextStyle(fontWeight: FontWeight.bold)),
            const Text("Semoga materi praktikum ke depannya terus dipertahankan kualitasnya dan porsi latihan coding-nya diperbanyak."),
            const Spacer(), // Mendorong tombol logout ke posisi paling bawah halaman
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: const Size(double.infinity, 45), // Tombol full-width yang simpel
              ),
              onPressed: () async {
                SharedPreferences p = await SharedPreferences.getInstance();
                await p.remove('currentUser');
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context, 
                    MaterialPageRoute(builder: (c) => const LoginView()), 
                    (r) => false,
                  );
                }
              },
              child: const Text('LOGOUT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}