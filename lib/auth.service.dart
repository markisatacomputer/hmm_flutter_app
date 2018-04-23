import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<bool> login([String u, String p]) async {
    //  Already logged in?
    bool test = await _testLoggedIn();
    if (test) {
      return true;
    //  Login - 1st w args 2nd w stored
    } else {
      print("Logging In...");
      final prefs = await SharedPreferences.getInstance();
      final email = u ?? prefs.getString('email');
      final password = p ?? prefs.getString('password');
      if (email != null && password != null) {
        final response = await _login(email, password);
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        final res = json.decode(response.body);

        //  Store
        if (res['token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('myprecious', res['token']);
          prefs.setString('email', email);
          prefs.setString('password', password);

          return true;
        }
      }
    }

    return false;
  }

  Future<bool> logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('myprecious');
    prefs.remove('email');
    prefs.remove('password');
    return true;
  }

  Future<http.Response> _login(String email, String password) async {
    final uri = new Uri.https('api.homemademess.com', '/auth/local');
    final httpClient = new http.Client();
    return httpClient.post(
      uri,
      headers: {
        'accept': 'application/json',
        'origin': 'https://homemademess.com'
      },
      body: {
        "email": email,
        "password": password,
      },
    );
  }

  Future<bool> _testLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('myprecious');

    if (token != null) {
      print("Testing saved token...");
      final uri = new Uri.https('api.homemademess.com', '/user/me');
      final httpClient = new http.Client();
      final res = await httpClient.get(
        uri,
        headers: {
          'accept': 'application/json',
          'origin': 'https://homemademess.com',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) return true;
    }

    return false;
  }
}
