import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Session extends ChangeNotifier {
  String _user = "";
  String _pass = "";

  String get user => _user;
  String get pass => _pass;

  set user(String value) {
    _user = value;
  }

  set pass(String value) {
    _pass = value;
  }

  Future<void> getSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _user = prefs.getString('user') ?? "";
    _pass = prefs.getString('pass') ?? "";
    notifyListeners();
  }

  Future<void> login() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', _user);
    await prefs.setString('pass', _pass);
    notifyListeners();
  }

  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await prefs.remove('pass');
    _user = "";
    _pass = "";
    notifyListeners();
  }
}
