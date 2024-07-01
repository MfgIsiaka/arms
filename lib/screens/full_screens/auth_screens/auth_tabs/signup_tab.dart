import 'dart:io';

import 'package:arms/screens/full_screens/home_screen.dart';
import 'package:arms/services/common_responses.dart';
import 'package:arms/services/common_variables.dart';
import 'package:arms/services/database_services.dart';
import 'package:arms/services/provider_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class SignupTab extends StatefulWidget {
  const SignupTab({super.key});

  @override
  State<SignupTab> createState() => _SignupTabState();
}

class _SignupTabState extends State<SignupTab> {
  File? _pickedFile;
  final _auth = FirebaseAuth.instance;
  AppDataProvider? _provider;
  final _usersRef = FirebaseFirestore.instance.collection("USERS");
  String _countryCode = "+255";
  final _fNameController = TextEditingController();
  final _lNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    _provider = Provider.of<AppDataProvider>(context);
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 10,
          ),
          _pickedFile == null
              ? GestureDetector(
                  onTap: () async {
                    final res = await ImagePicker.platform
                        .pickImage(source: ImageSource.gallery);
                    setState(() {
                      _pickedFile = File(res!.path);
                    });
                  },
                  child: CircleAvatar(
                      radius: 70,
                      child: Icon(
                        Icons.person,
                        size: 50,
                      )),
                )
              : Container(
                  height: 130,
                  width: 130,
                  decoration: BoxDecoration(
                      color: redColor,
                      boxShadow: [BoxShadow(color: blackColor, blurRadius: 10)],
                      borderRadius: BorderRadius.circular(70),
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: FileImage(
                            _pickedFile!,
                          ))),
                ),
          SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 45,
            child: TextField(
              controller: _fNameController,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  label: Text("First name"),
                  border: OutlineInputBorder()),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          SizedBox(
            height: 45,
            child: TextField(
              controller: _lNameController,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person_add),
                  label: Text("Last name"),
                  border: OutlineInputBorder()),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          SizedBox(
            height: 45,
            child: TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  prefixIcon: FittedBox(
                    fit: BoxFit.contain,
                    child: CountryCodePicker(
                      initialSelection: "tanzania",
                      onChanged: (CountryCode code) {
                        _countryCode = code.toString();
                      },
                    ),
                  ),
                  labelText: "Phone number",
                  border: OutlineInputBorder()),
            ),
          ),
          SizedBox(
            height: 5,
          ),
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
          SizedBox(
            height: 45,
            child: TextField(
              controller: _cPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                  label: Text("Repeat password"), border: OutlineInputBorder()),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          ElevatedButton(
              onPressed: () async {
                var fName = _fNameController.text;
                var lName = _lNameController.text;
                var phone = _phoneController.text;
                var email = _emailController.text;
                var pass = _passwordController.text;
                var cPass = _cPasswordController.text;

                if (fName.isNotEmpty &&
                    lName.isNotEmpty &&
                    phone.isNotEmpty &&
                    email.isNotEmpty &&
                    pass.isNotEmpty &&
                    cPass.isNotEmpty) {
                  if (pass.length >= 6) {
                    if (_pickedFile != null) {
                      if (pass == cPass) {
                        CommonResponses().showLoadingDialog(context);
                        var res = await DatabaseServices().signUpUser({
                          "first_name": fName,
                          "last_name": lName,
                          "phone": _countryCode + phone,
                          "email": email,
                          "password": pass,
                          "profile_photo": _pickedFile
                        });
                        Navigator.pop(context);
                        if (res['msg'] == "done") {
                          await getLogedInUser();
                        } else {
                          Fluttertoast.showToast(msg: res['msg']);
                        }
                      } else {
                        Fluttertoast.showToast(
                            msg: "Two passwords must be similar");
                      }
                    } else {
                      Fluttertoast.showToast(msg: "Your image is needed!!");
                    }
                  } else {
                    Fluttertoast.showToast(
                        msg: "Password should be six or more characters!!");
                  }
                } else {
                  Fluttertoast.showToast(msg: "All details are required!!");
                }
              },
              child: Text("Signup"))
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
      CommonResponses().showToast("Retrying..");
      getLogedInUser();
    });
  }
}
