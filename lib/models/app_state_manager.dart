import 'dart:async';
import 'package:flutter/material.dart';
import 'models.dart';

class TrendyMoviesMangaer {
  static const int explore = 0;
  static const int dishes = 1;
  static const int gptNutrition = 2;
}

// AppStateManager mocks the various app state such as app initialization,
// app login.
class AppStateManager extends ChangeNotifier {
  // Checks to see if the user is logged in
  bool _loggedIn = false;

  User? _user;
  // Records the current tab the user is on.
  int _selectedTab = TrendyMoviesMangaer.explore;
  // Stores user state properties on platform specific file system.
  final _appCache = AppCache();

  User? get user => _user;

  // Property getters.
  bool get isLoggedIn => _loggedIn;
  int get getSelectedTab => _selectedTab;

  // Initializes the app
  Future<void> initializeApp() async {
    // Check if the user is logged in
    _loggedIn = await _appCache.isUserLoggedIn();
  }

  void login(String username, String password) async {
    _loggedIn = true;
    await _appCache.cacheUser();
    notifyListeners();
  }

  void goToTab(index) {
    _selectedTab = index;
    notifyListeners();
  }

  void goToDishes() {
    _selectedTab = TrendyMoviesMangaer.dishes;
    notifyListeners();
  }

  void logout() async {
    // Reset all properties once user logs out
    _loggedIn = false;
    _selectedTab = 0;

    // Reinitialize the app
    await _appCache.invalidate();
    await initializeApp();
    notifyListeners();
  }
}
