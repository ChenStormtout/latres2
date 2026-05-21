import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

class FavoriteSpellsView extends StatefulWidget {
  const FavoriteSpellsView({super.key});

  @override
  State<FavoriteSpellsView> createState() => _FavoriteSpellsViewState();
}

class _FavoriteSpellsViewState extends State<FavoriteSpellsView> {
  List<dynamic> _favSpellsDetails = [];
  String _currentUser = '';

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentUser = prefs.getString('currentUser') ?? '';
    List<String> favNames = prefs.getStringList('fav_spells_$_currentUser') ?? [];
    
    List<dynamic> details = [];
    for (String name in favNames) {
      String? jsonStr = prefs.getString('fav_detail_${_currentUser}_$name');
      if (jsonStr != null) {
        details.add(json.decode(jsonStr));
      }
    }
    setState(() => _favSpellsDetails = details);
  }

  void _deleteFavorite(String spellName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favNames = prefs.getStringList('fav_spells_$_currentUser') ?? [];
    
    favNames.remove(spellName);
    await prefs.setStringList('fav_spells_$_currentUser', favNames);
    await prefs.remove('fav_detail_${_currentUser}_$spellName');
    
    _loadFavorites();
    await NotificationService.showNotification('Mantra Dihapus', 'Mantra "$spellName" telah dihapus dari daftar favorit Anda.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Favorite Spells')),
      body: _favSpellsDetails.isEmpty
          ? const Center(child: Text('Belum ada mantra favorit.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _favSpellsDetails.length,
              itemBuilder: (context, index) {
                final spell = _favSpellsDetails[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text(spell['spell'], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
                    subtitle: Text(spell['use']),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.grey),
                      onPressed: () => _deleteFavorite(spell['spell']),
                    ),
                  ),
                );
              },
            ),
    );
  }
}