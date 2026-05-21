import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'login_view.dart';
import 'profile_view.dart';
import 'spells_view.dart';

class BooksView extends StatefulWidget {
  const BooksView({super.key});
  @override
  State<BooksView> createState() => _BooksViewState();
}

class _BooksViewState extends State<BooksView> {
  List _books = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  _getData() async {
    try {
      final res = await http.get(Uri.parse('https://potterapi-fedeperin.vercel.app/en/books'));
      if (res.statusCode == 200) setState(() => _books = json.decode(res.body));
    } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Books View'),
        actions: [
          IconButton(icon: const Icon(Icons.person), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileView()))),
          IconButton(icon: const Icon(Icons.logout), onPressed: () async {
            SharedPreferences p = await SharedPreferences.getInstance();
            await p.remove('currentUser');
            if (context.mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginView()), (r) => false);
          }),
        ],
      ),
      body: _loading 
          ? const Center(child: CircularProgressIndicator()) 
          : ListView.builder(
              itemCount: _books.length,
              itemBuilder: (c, i) => ListTile(
                leading: Image.network(_books[i]['cover'], width: 40, errorBuilder: (c, e, s) => const Icon(Icons.book)),
                title: Text(_books[i]['title']),
                subtitle: Text(_books[i]['releaseDate']),
                onTap: () => Navigator.push(c, MaterialPageRoute(builder: (c) => DetailBookView(book: _books[i]))),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Text('Spell'),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const SpellsView())),
      ),
    );
  }
}

class DetailBookView extends StatelessWidget {
  final dynamic book;
  const DetailBookView({super.key, this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(book['title'])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.network(book['cover'], height: 200),
            const SizedBox(height: 10),
            Text("Judul: ${book['title']}", style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("Tanggal Rilis: ${book['releaseDate']}"),
            Text("Pages: ${book['pages']}"),
            Text("Deskripsi: ${book['description']}"),
          ],
        ),
      ),
    );
  }
}