import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'login_view.dart';
import 'favorite_spells_view.dart';

class SpellsView extends StatefulWidget {
  const SpellsView({super.key});
  @override
  State<SpellsView> createState() => _SpellsViewState();
}

class _SpellsViewState extends State<SpellsView> {
  List _spells = [];
  List<String> _favs = [];
  bool _loading = true;
  String _user = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  _load() async {
    SharedPreferences p = await SharedPreferences.getInstance();
    _user = p.getString('currentUser') ?? '';
    _favs = p.getStringList('fav_spells_$_user') ?? [];
    try {
      final res = await http.get(Uri.parse('https://potterapi-fedeperin.vercel.app/en/spells'));
      if (res.statusCode == 200) setState(() => _spells = json.decode(res.body));
    } catch (_) {}
    setState(() => _loading = false);
  }

  _toggle(dynamic spell) async {
    SharedPreferences p = await SharedPreferences.getInstance();
    String name = spell['spell'];
    setState(() {
      if (_favs.contains(name)) {
        _favs.remove(name);
        p.remove('fav_detail_${_user}_$name');
      } else {
        _favs.add(name);
        p.setString('fav_detail_${_user}_$name', json.encode(spell));
      }
    });
    await p.setStringList('fav_spells_$_user', _favs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spells View'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () async {
            SharedPreferences p = await SharedPreferences.getInstance();
            await p.remove('currentUser');
            if (context.mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => const LoginView()), (r) => false);
          })
        ],
      ),
      body: _loading 
          ? const Center(child: CircularProgressIndicator()) 
          : ListView.builder(
              itemCount: _spells.length,
              itemBuilder: (c, i) => ListTile(
                title: Text(_spells[i]['spell']),
                subtitle: Text(_spells[i]['use']),
                trailing: IconButton(
                  icon: Icon(_favs.contains(_spells[i]['spell']) ? Icons.favorite : Icons.favorite_border, color: Colors.red),
                  onPressed: () => _toggle(_spells[i]),
                ),
              ),
            ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Books')),
          ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const FavoriteSpellsView())).then((_) => _load()), child: const Text('Favorites')),
        ],
      ),
    );
  }
}