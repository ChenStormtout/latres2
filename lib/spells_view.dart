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
  List<dynamic> _spells = [];
  List<String> _favSpellNames = [];
  bool _isLoading = true;
  String _currentUser = '';

  @override
  void initState() {
    super.initState();
    _loadUserDataAndSpells();
  }

  Future<void> _loadUserDataAndSpells() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentUser = prefs.getString('currentUser') ?? '';
    _favSpellNames = prefs.getStringList('fav_spells_$_currentUser') ?? [];
    
    try {
      final response = await http.get(Uri.parse('https://potterapi-fedeperin.vercel.app/en/spells'));
      if (response.statusCode == 200) {
        setState(() {
          _spells = json.decode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _toggleFavorite(dynamic spell) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String spellName = spell['spell'];
    
    setState(() {
      if (_favSpellNames.contains(spellName)) {
        _favSpellNames.remove(spellName);
        prefs.remove('fav_detail_${_currentUser}_$spellName');
      } else {
        _favSpellNames.add(spellName);
        prefs.setString('fav_detail_${_currentUser}_$spellName', json.encode(spell));
      }
    });
    
    await prefs.setStringList('fav_spells_$_currentUser', _favSpellNames);
  }

  void _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUser');
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginView()), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spells List'),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () => _logout(context))],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _spells.length,
              itemBuilder: (context, index) {
                final spell = _spells[index];
                final isFav = _favSpellNames.contains(spell['spell']);
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text(spell['spell'], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
                    subtitle: Text(spell['use']),
                    trailing: IconButton(
                      icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: Colors.red),
                      onPressed: () => _toggleFavorite(spell),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF1A237E),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.book, color: Colors.white),
              label: const Text('Books', style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.pop(context),
            ),
            const VerticalDivider(color: Colors.white30, width: 1),
            TextButton.icon(
              icon: const Icon(Icons.favorite, color: Colors.white),
              label: const Text('Favorites', style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoriteSpellsView())).then((_) => _loadUserDataAndSpells()),
            ),
          ],
        ),
      ),
    );
  }
}