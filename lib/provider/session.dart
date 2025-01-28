import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Session extends ChangeNotifier {
  String _user = "";
  String _pass = "";
  int _indexServicio = 0;

  String get user => _user;
  String get pass => _pass;
  int get indexServicio => _indexServicio;

  set user(String value) {
    _user = value;
  }

  set pass(String value) {
    _pass = value;
  }

  Future<bool> login() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', _user);
    await prefs.setString('pass', _pass);
    notifyListeners();
    return true;
  }

  Future<bool> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _user = "";
    _pass = "";
    _indexServicio = 0;
    await prefs.setString('user', _user);
    await prefs.setString('pass', _pass);
    await prefs.setString('idServicio', _indexServicio.toString());
    notifyListeners();
    return true;
  }

  Future<void> setIndexService(int value) async {
    _indexServicio = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('idServicio', _indexServicio.toString());
  }
}
