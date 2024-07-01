import 'package:arms/screens/full_screens/admin_home_screen.dart';
import 'package:arms/screens/full_screens/home_screen.dart';
import 'package:arms/services/common_responses.dart';
import 'package:arms/services/common_variables.dart';
import 'package:arms/services/provider_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _auth = FirebaseAuth.instance;
  final _usersRef = FirebaseFirestore.instance.collection("USERS");
  late AppDataProvider _provider;

  getLogedInUser() async {
    var userId = _auth.currentUser!.uid;
    print("im in" + _auth.currentUser!.uid.toString());
    await _usersRef.doc(_auth.currentUser!.uid).get().then((value) {
      print("im innnner ");
      if (value.exists) {
        _provider.currentUser = value.data()!;
        CommonResponses().showToast("welcome");
        if (value.data()!['role'] == "admin") {
          CommonResponses()
              .shiftPage(context, const AdminHomeScreen(), kill: true);
        } else {
          CommonResponses().shiftPage(context, const HomeScreen(), kill: true);
        }
      } else {
        print("No user record match");
      }
    }).catchError((e) {
      CommonResponses().showToast("Retrying..", isError: true);
      getLogedInUser();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (_auth.currentUser == null) {
      print("No user");
      Future.delayed(Duration(seconds: 10), () {
        Navigator.push(
            context,
            PageTransition(
                child: HomeScreen(),
                duration: Duration(seconds: 1),
                type: PageTransitionType.rightToLeft));
      });
    } else {
      getLogedInUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    _provider = Provider.of<AppDataProvider>(context);
    return Scaffold(
      body: Container(
        color: Colors.blue,
        padding: const EdgeInsets.only(bottom: 10),
        width: screenSize.width,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/app_logo.png",
                      width: 100,
                    ),
                    Text(
                      "ARMS",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    )
                  ],
                ),
              )),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SpinKitRipple(
                    size: 40,
                    duration: Duration(milliseconds: 1000),
                    color: whiteColor,
                  ),
                  Text("Apartment Rental Management System",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: appColor,
                      ))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
