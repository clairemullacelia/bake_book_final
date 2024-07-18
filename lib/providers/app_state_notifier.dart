import 'package:flutter/material.dart';

class AppStateNotifier extends ChangeNotifier {
  bool isLoggedIn = false;

  void updateLoginStatus(bool status) {
    isLoggedIn = status;
    notifyListeners();
  }
}
