import 'package:flutter/material.dart';

class NavigationProvider with ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void setIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void switchToHome() => setIndex(0);
  void switchToAnalytics() => setIndex(1);
  void switchToBudget() => setIndex(2);
  void switchToSettings() => setIndex(3);
}
