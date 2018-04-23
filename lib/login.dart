import 'auth.service.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({ Key key }) : super(key: key);

  @override
  LoginFormState createState() => new LoginFormState();
}

class PasswordField extends StatefulWidget {
  const PasswordField({
    this.fieldKey,
    this.labelText,
    this.onFieldSubmitted,
    this.controller,
    this.initialValue,
  });

  final Key fieldKey;
  final String labelText;
  final ValueChanged<String> onFieldSubmitted;
  final TextEditingController controller;
  final String initialValue;

  @override
  _PasswordFieldState createState() => new _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return new TextFormField(
      key: widget.fieldKey,
      controller: widget.controller,
      obscureText: _obscureText,
      onFieldSubmitted: widget.onFieldSubmitted,
      initialValue: widget.initialValue,
      decoration: new InputDecoration(
        border: const UnderlineInputBorder(),
        filled: true,
        labelText: widget.labelText,
        suffixIcon: new GestureDetector(
          onTap: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          child: new Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
        ),
      ),
    );
  }
}

class LoginFormState extends State<LoginForm> {
  final AuthService auth = new AuthService();
  final GlobalKey<FormState> _loginKey = new GlobalKey<FormState>();
  final usernameController = new TextEditingController();
  final passwordController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Login"),
      ),
      body: new Form(
        key: _loginKey,
        child: new Column(
          children: <Widget>[
            new TextFormField(
              decoration: const InputDecoration(
                border: const UnderlineInputBorder(),
                filled: true,
                labelText: 'Username *',
              ),
              controller: usernameController,
            ),
            new PasswordField(
              labelText: 'Password *',
              controller: passwordController,
            ),
            new Center(
              child: new RaisedButton(
                child: const Text('SUBMIT'),
                onPressed: () => _handleSubmitted(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmitted() async {
    if (_loginKey.currentState.validate()) {
      auth.login(usernameController.text, passwordController.text).then((loggedIn){
        if (loggedIn) {
          Navigator.of(context).pushReplacementNamed('/gallery');
        }
      });
    }
  }

}
