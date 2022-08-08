import 'package:flutter/material.dart';
import 'package:scomb_mobile/ui/bottom_navigation.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ログイン"),
      ),
      body: Center(
          child: OutlinedButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const BottomNavigationWidget()));
        },
        child: const Text("login_successful"),
      )),
    );
  }
}
