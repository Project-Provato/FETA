import 'package:flutter/material.dart';

class LanguageService extends ChangeNotifier {
  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;

  void changeLanguage(String languageCode) {
    _currentLocale = Locale(languageCode);
    notifyListeners();
  }

  bool get isEnglish => _currentLocale.languageCode == 'en';
  bool get isGreek => _currentLocale.languageCode == 'el';
}