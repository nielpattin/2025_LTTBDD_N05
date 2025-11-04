import 'package:flutter/foundation.dart';

class GameState extends ChangeNotifier {
  void reset() {
    notifyListeners();
  }
}
