import 'package:arms/screens/full_screens/admin_home_screen.dart';
import 'package:arms/screens/full_screens/home_screen.dart';
import 'package:arms/services/common_responses.dart';
import 'package:arms/services/common_variables.dart';
import 'package:arms/services/database_services.dart';
import 'package:arms/services/provider_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class SigninTab extends StatefulWidget {
  const SigninTab({super.key});

  @override
  State<SigninTab> createState() => _SigninTabState();
}

class _SigninTabState extends State<SigninTab> {
  final _auth = FirebaseAuth.instance;
  final _usersRef = FirebaseFirestore.instance.collection("USERS");
  AppDataProvider? _provider;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    _provider = Provider.of<AppDataProvider>(context);
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 45,
            child: TextField(
              controller: _emailController,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email),
                  label: Text("Email address"),
                  border: OutlineInputBorder()),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          SizedBox(
            height: 45,
            child: TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.security),
                  label: Text("Password"),
                  border: OutlineInputBorder()),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          ElevatedButton(
              onPressed: () async {
                var email = _emailController.text.trim();
                var password = _passwordController.text.trim();
                if (email.isNotEmpty && password.isNotEmpty) {
                  CommonResponses().showLoadingDialog(context);
                  var res = await DatabaseServices()
                      .signInUser({"email": email, "password": password});
                  Navigator.pop(context);
                  if (res['msg'] == "done") {
                    await getLogedInUser();
                  } else {
                    Fluttertoast.showToast(msg: res['msg']);
                  }
                } else {
                  Fluttertoast.showToast(msg: "All details are requred!!");
                }
              },
              child: Text("Signin"))
        ],
      ),
    );
  }

  getLogedInUser() async {
    var userId = _auth.currentUser!.uid;
    await _usersRef.doc(userId).get().then((value) {
      _provider!.currentUser = value.data()!;
      CommonResponses().showToast("welcome");
      if (value.data()!['role'] == "admin") {
        CommonResponses()
            .shiftPage(context, const AdminHomeScreen(), kill: true);
      } else {
        CommonResponses().shiftPage(context, const HomeScreen(), kill: true);
      }
    }).catchError((e) {
      CommonResponses().showToast("Retrying..");
      getLogedInUser();
    });
  }
}
