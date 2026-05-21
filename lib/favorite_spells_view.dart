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
  List _favDetails = [];
  String _user = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  _load() async {
    SharedPreferences p = await SharedPreferences.getInstance();
    _user = p.getString('currentUser') ?? '';
    List<String> names = p.getStringList('fav_spells_$_user') ?? [];
    List temp = [];
    for (String n in names) {
      String? j = p.getString('fav_detail_${_user}_$n');
      if (j != null) temp.add(json.decode(j));
    }
    setState(() => _favDetails = temp);
  }

  _delete(String name) async {
    SharedPreferences p = await SharedPreferences.getInstance();
    List<String> names = p.getStringList('fav_spells_$_user') ?? [];
    names.remove(name);
    await p.setStringList('fav_spells_$_user', names);
    await p.remove('fav_detail_${_user}_$name');
    _load();
    await NotificationService.showNotification('Mantra Dihapus', 'Mantra "$name" telah dihapus.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorite Spells')),
      body: _favDetails.isEmpty 
          ? const Center(child: Text('Kosong')) 
          : ListView.builder(
              itemCount: _favDetails.length,
              itemBuilder: (c, i) => ListTile(
                title: Text(_favDetails[i]['spell']),
                subtitle: Text(_favDetails[i]['use']),
                trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => _delete(_favDetails[i]['spell'])),
              ),
            ),
    );
  }
}