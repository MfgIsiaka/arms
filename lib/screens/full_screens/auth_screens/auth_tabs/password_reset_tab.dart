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

class PasswordResetTab extends StatefulWidget {
  const PasswordResetTab({super.key});

  @override
  State<PasswordResetTab> createState() => _PasswordResetTabState();
}

class _PasswordResetTabState extends State<PasswordResetTab> {
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
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.email),
                  label: Text("Email address"),
                  border: OutlineInputBorder()),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          ElevatedButton(
              onPressed: () async {
                var email = _emailController.text.trim();
                if (email.isNotEmpty) {
                  CommonResponses().showLoadingDialog(context);

                  await _auth
                      .sendPasswordResetEmail(email: email)
                      .then((value) {
                    Navigator.pop(context);
                    CommonResponses().showToast("Open your email to continue");
                  }).catchError((e) {
                    Navigator.pop(context);
                    CommonResponses().showToast(e.toString(), isError: true);
                  });
                } else {
                  Fluttertoast.showToast(msg: "All details are requred!!");
                }
              },
              child: const Text("Send reset link"))
        ],
      ),
    );
  }

  getLogedInUser() async {
    var userId = _auth.currentUser!.uid;
    await _usersRef.doc(userId).get().then((value) {
      _provider!.currentUser = value.data()!;
      CommonResponses().showToast("welcome");
      CommonResponses().shiftPage(context, HomeScreen(), kill: true);
    }).catchError((e) {
      //print(e.toString());
      CommonResponses().showToast("Retrying..");
      getLogedInUser();
    });
  }
}
