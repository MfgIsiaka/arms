import 'package:arms/screens/full_screens/auth_screens/auth_tabs/password_reset_tab.dart';
import 'package:flutter/material.dart';
import 'package:arms/services/common_variables.dart';
import 'package:arms/screens/full_screens/auth_screens/auth_tabs/signin_tab.dart';
import 'package:arms/screens/full_screens/auth_screens/auth_tabs/signup_tab.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          appBar: AppBar(
            elevation: 4,
            shadowColor: blackColor,
            bottom: const TabBar(tabs: [
              Tab(
                text: "Signin",
              ),
              Tab(
                text: "Signup",
              ),
              Tab(
                text: "Reset password",
              )
            ]),
            title: const Text("Get in"),
          ),
          body: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
                child: TabBarView(
                    children: [SigninTab(), SignupTab(), PasswordResetTab()])),
          )),
    );
  }
}
