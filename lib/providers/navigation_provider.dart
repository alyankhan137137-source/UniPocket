import 'package:flutter/material.dart';

/// A provider that manages the global navigation state of the application.
/// 
/// This class tracks the currently selected index of the main bottom 
/// navigation bar and provides methods to switch between different 
/// top-level screens (Home, Analytics, Budget, and Settings).
class NavigationProvider with ChangeNotifier {
  int _selectedIndex = 0;

  /// The index of the currently active screen in the [MainNavigationScreen].
  int get selectedIndex => _selectedIndex;

  /// Updates the navigation index and notifies listeners to refresh the UI.
  void setIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  /// Navigates the user to the Home screen (Index 0).
  void switchToHome() => setIndex(0);
  
  /// Navigates the user to the Analytics screen (Index 1).
  void switchToAnalytics() => setIndex(1);
  
  /// Navigates the user to the Budget screen (Index 2).
  void switchToBudget() => setIndex(2);
  
  /// Navigates the user to the Profile/Settings screen (Index 3).
  void switchToSettings() => setIndex(3);
}
