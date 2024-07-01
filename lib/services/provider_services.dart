import 'package:flutter/material.dart';

class AppDataProvider extends ChangeNotifier {
  Map<String, dynamic> _currentUser = {};

  Map<String, dynamic> get currentUser => _currentUser;

  set currentUser(Map<String, dynamic> currentUser) {
    _currentUser = currentUser;
    notifyListeners();
  }
}
