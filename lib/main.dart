import 'package:flutter/material.dart';
import 'package:scomb_mobile/basic_auth_test.dart';
import 'package:scomb_mobile/ui/login/login_screen.dart';

void main() {
  // runApp(const MyApp());
  runApp(TestApp());
}

class ScombMobile extends StatelessWidget {
  const ScombMobile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "ScombMobile",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
    );
  }
}
