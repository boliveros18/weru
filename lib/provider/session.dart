import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Session extends ChangeNotifier {
  String _user = "";
  String _pass = "";
  String _nit = "";
  bool _deviceId = false;
  bool _masters = false;

  String get user => _user;
  String get pass => _pass;
  String get nit => _nit;
  bool get deviceId => _deviceId;
  bool get masters => _masters;

  set user(String value) {
    _user = value;
    login();
    notifyListeners();
  }

  set pass(String value) {
    _pass = value;
    login();
    notifyListeners();
  }

  set nit(String value) {
    _nit = value;
    login();
    notifyListeners();
  }

  set deviceId(bool value) {
    _deviceId = value;
    login();
    notifyListeners();
  }

  set masters(bool value) {
    _masters = value;
    login();
    notifyListeners();
  }

  Future<void> getSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _user = prefs.getString('user') ?? "";
    _pass = prefs.getString('pass') ?? "";
    _nit = prefs.getString('nit') ?? "";
    _deviceId = prefs.getBool('deviceId') ?? false;
    _masters = prefs.getBool('masters') ?? false;
    notifyListeners();
  }

  Future<void> login() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', _user);
    await prefs.setString('pass', _pass);
    await prefs.setString('nit', _nit);
    await prefs.setBool('deviceId', _deviceId);
    await prefs.setBool('masters', _masters);
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
