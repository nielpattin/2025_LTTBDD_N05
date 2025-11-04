import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayerProfile extends ChangeNotifier {
  int _coins = 0;

  int get coins => _coins;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _coins = prefs.getInt('coins') ?? 0;
    notifyListeners();
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coins', _coins);
  }

  void addCoins(int amount) {
    _coins += amount;
    save();
    notifyListeners();
  }

  void spendCoins(int amount) {
    if (_coins >= amount) {
      _coins -= amount;
      save();
      notifyListeners();
    }
  }

  Future<void> resetProfile() async {
    _coins = 0;
    await save();
    notifyListeners();
  }
}
