import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

final scaffoldBackgroundColor = Color(0xff202832);

@RoutePage()
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: scaffoldBackgroundColor);
  }
}
