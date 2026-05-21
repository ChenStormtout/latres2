import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
            const Text("Praktikum ini melatih kemampuan logika penanganan data API dan local storage dengan sangat baik."),
            const SizedBox(height: 10),
            const Text("Pesan:", style: TextStyle(fontWeight: FontWeight.bold)),
            const Text("Semoga materi praktikum ke depan terus memberikan case study yang relevan dengan kebutuhan industri."),
          ],
        ),
      ),
    );
  }
}