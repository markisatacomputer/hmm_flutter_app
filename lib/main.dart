import 'package:flutter/material.dart';

import 'auth.service.dart';
import 'login.dart';
import 'gallery.dart';

void main() async {
  // Set default home.
  Widget _defaultHome = new LoginForm();

  // Get result of the login function.
  final AuthService auth = new AuthService();
  bool _result = await auth.login();
  if (_result) {
    _defaultHome = new Gallery();
  }


  runApp(new MaterialApp(
    title: 'homemademess',
    theme: new ThemeData(
      // This is the theme of your application.
      //
      // Try running your application with "flutter run". You'll see the
      // application has a blue toolbar. Then, without quitting the app, try
      // changing the primarySwatch below to Colors.green and then invoke
      // "hot reload" (press "r" in the console where you ran "flutter run",
      // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
      // counter didn't reset back to zero; the application is not restarted.
      primarySwatch: Colors.blue,
    ),
    home: _defaultHome,
    routes: <String, WidgetBuilder>{
      '/gallery': (BuildContext context) => new Gallery(),
    },
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'homemademess',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: new LoginForm(),
    );
  }
}
