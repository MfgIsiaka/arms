import 'package:arms/screens/full_screens/apartment_details_screen.dart';
import 'package:arms/screens/full_screens/auth_screens/authentication_screen.dart';
import 'package:arms/screens/full_screens/profile_screen.dart';
import 'package:arms/screens/full_screens/property_filter_screens/location_filter_screen.dart';
import 'package:arms/screens/full_screens/property_filter_screens/general_filter_screen.dart';
import 'package:arms/screens/full_screens/property_upload_screen.dart';
import 'package:arms/services/common_responses.dart';
import 'package:arms/services/common_variables.dart';
import 'package:arms/services/database_services.dart';
import 'package:arms/services/modal_services.dart';
import 'package:arms/services/provider_services.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:marquee/marquee.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  AppDataProvider? _provider;
  Map<String, dynamic> _propresult = {};
  final _auth = FirebaseAuth.instance;
  List _properties = [];
  Future<void> _getProperties() async {
    _propresult = {};
    var res = await DatabaseServices().retriveProperty("");
    setState(() {
      _loading = false;
      _propresult = res;
      if (_propresult['msg'] == 'done' && _propresult['data'] != null) {
        _properties = (_propresult['data'] as List)
            .where((el) => (el['active_status'] == 'Active' &&
                el['approval_status'] == 'Approved'))
            .toList();
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getProperties();
  }

  @override
  Widget build(BuildContext context) {
    _provider = Provider.of<AppDataProvider>(context);
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        color: appColor,
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 40,
                      child: Row(
                        children: [
                          Text(
                            "ARMS",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: whiteColor),
                          ),
                          Expanded(
                            child: Container(
                              child: Image.asset(
                                "assets/images/app_logo.png",
                                color: greyColor,
                                height: 30,
                              ),
                            ),
                          ),
                          _auth.currentUser == null
                              ? IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            child: AuthenticationScreen(),
                                            type: PageTransitionType
                                                .rightToLeft));
                                  },
                                  icon: Icon(
                                    Icons.login,
                                    color: whiteColor,
                                  ))
                              : GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            child: ProfileScreen(),
                                            type: PageTransitionType
                                                .rightToLeft));
                                  },
                                  child: AbsorbPointer(
                                    child: Container(
                                      height: 45,
                                      width: 45,
                                      decoration: BoxDecoration(
                                          color: greyColor,
                                          boxShadow: [
                                            BoxShadow(
                                                color: blackColor,
                                                blurRadius: 10)
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: NetworkImage(
                                                _provider!.currentUser[
                                                    'profile_photo'],
                                              ))),
                                    ),
                                  ),
                                )
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Navigator.push(
                            //     context,
                            //     PageTransition(
                            //         child: const LocationFilterScreen(),
                            //         type: PageTransitionType.rightToLeft));
                          },
                          child: AbsorbPointer(
                            child: Container(
                              padding: EdgeInsets.all(2),
                              width: screenSize.width * 0.4,
                              height: 25,
                              decoration: BoxDecoration(
                                  color: const Color.fromARGB(113, 0, 0, 0),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: yellowColor,
                                  ),
                                  Expanded(
                                    child: Marquee(
                                      startAfter: Duration(seconds: 3),
                                      blankSpace: screenSize.width * 0.4,
                                      pauseAfterRound: Duration(seconds: 2),
                                      text: "All Tanzania regions",
                                      style: TextStyle(color: whiteColor),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Expanded(
                  child: Container(
                decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    )),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(5),
                      child: _propresult == null || _propresult['data'] == null
                          ? null
                          : Text(
                              "${_properties.length} properties found.",
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                    ),
                    Expanded(
                        child: _propresult.isEmpty || _loading
                            ? Center(
                                child: SpinKitCircle(
                                  color: appColor,
                                  size: 35,
                                ),
                              )
                            : _propresult['msg'] == 'done'
                                ? _propresult['data'].isEmpty
                                    ? const Center(
                                        child: Text('No apartment found'),
                                      )
                                    : StatefulBuilder(
                                        builder: (context, stateSetter) {
                                        return ListView.builder(
                                            itemCount: _properties.length,
                                            itemBuilder: (context, index) {
                                              Map<String, dynamic> prop =
                                                  _properties[index];
                                              return GestureDetector(
                                                onTap: () async {
                                                  await Navigator.push(
                                                          context,
                                                          PageTransition(
                                                              child:
                                                                  ApartmentDetailsScreen(
                                                                      prop),
                                                              type: PageTransitionType
                                                                  .rightToLeft))
                                                      .then((value) async {
                                                    await _getProperties();
                                                    setState(() {});
                                                  });
                                                },
                                                child: AbsorbPointer(
                                                  child: Container(
                                                    margin: EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                        color: whiteColor,
                                                        boxShadow: [
                                                          BoxShadow(
                                                              color: blackColor,
                                                              blurRadius: 2)
                                                        ]),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          decoration:
                                                              const BoxDecoration(
                                                            borderRadius: BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        10),
                                                                topRight: Radius
                                                                    .circular(
                                                                        10)),
                                                          ),
                                                          width:
                                                              screenSize.width,
                                                          height: (9 / 16) *
                                                              screenSize.width,
                                                          child: Stack(
                                                            alignment: Alignment
                                                                .topCenter,
                                                            children: [
                                                              Container(
                                                                decoration:
                                                                    const BoxDecoration(
                                                                  borderRadius: BorderRadius.only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              10),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              10)),
                                                                ),
                                                                child:
                                                                    CachedNetworkImage(
                                                                  imageUrl:
                                                                      prop['images']
                                                                          [0],
                                                                  progressIndicatorBuilder: (context,
                                                                          url,
                                                                          progress) =>
                                                                      SpinKitCircle(
                                                                    color:
                                                                        appColor,
                                                                    size: 30,
                                                                  ),
                                                                  errorWidget:
                                                                      (context,
                                                                          ss,
                                                                          child) {
                                                                    return Container(
                                                                      child: Icon(
                                                                          Icons
                                                                              .error),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                              Positioned(
                                                                bottom: 0,
                                                                child:
                                                                    Container(
                                                                  width:
                                                                      screenSize
                                                                          .width,
                                                                  color: const Color
                                                                      .fromRGBO(
                                                                      0,
                                                                      0,
                                                                      0,
                                                                      0.5),
                                                                  child: Row(
                                                                    children: [
                                                                      Container(
                                                                        color:
                                                                            blackColor,
                                                                        padding:
                                                                            EdgeInsets.symmetric(horizontal: 2),
                                                                        child:
                                                                            Text(
                                                                          "1/${prop['images'].length}",
                                                                          style: TextStyle(
                                                                              color: whiteColor,
                                                                              fontSize: 10),
                                                                        ),
                                                                      ),
                                                                      Spacer(),
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.end,
                                                                        children: [
                                                                          Icon(
                                                                            Icons.bed_sharp,
                                                                            size:
                                                                                18,
                                                                            color:
                                                                                whiteColor,
                                                                            shadows: [
                                                                              Shadow(blurRadius: 10, color: Colors.black)
                                                                            ],
                                                                          ),
                                                                          Text(
                                                                            "6",
                                                                            style:
                                                                                const TextStyle(fontWeight: FontWeight.bold),
                                                                          )
                                                                        ],
                                                                      ),
                                                                      Icon(
                                                                        Icons
                                                                            .circle,
                                                                        size: 8,
                                                                        color: Colors
                                                                            .red,
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Icon(
                                                                            Icons.dining_outlined,
                                                                            size:
                                                                                18,
                                                                            color:
                                                                                whiteColor,
                                                                            shadows: [
                                                                              Shadow(blurRadius: 10, color: Colors.black)
                                                                            ],
                                                                          ),
                                                                          Text(
                                                                            "6",
                                                                            style:
                                                                                const TextStyle(fontWeight: FontWeight.bold),
                                                                          )
                                                                        ],
                                                                      ),
                                                                      Icon(
                                                                        Icons
                                                                            .circle,
                                                                        size: 8,
                                                                        color:
                                                                            appColor,
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Icon(
                                                                            Icons.chair,
                                                                            size:
                                                                                18,
                                                                            color:
                                                                                whiteColor,
                                                                            shadows: [
                                                                              Shadow(blurRadius: 10, color: Colors.black)
                                                                            ],
                                                                          ),
                                                                          Text(
                                                                            "6",
                                                                            style:
                                                                                const TextStyle(fontWeight: FontWeight.bold),
                                                                          )
                                                                        ],
                                                                      ),
                                                                      const Icon(
                                                                        Icons
                                                                            .circle,
                                                                        size: 8,
                                                                        color: Colors
                                                                            .green,
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Icon(
                                                                            Icons.bathroom_outlined,
                                                                            size:
                                                                                18,
                                                                            color:
                                                                                whiteColor,
                                                                            shadows: [
                                                                              Shadow(blurRadius: 10, color: Colors.black)
                                                                            ],
                                                                          ),
                                                                          Text(
                                                                            "6",
                                                                            style:
                                                                                const TextStyle(fontWeight: FontWeight.bold),
                                                                          )
                                                                        ],
                                                                      ),
                                                                      const Icon(
                                                                        Icons
                                                                            .circle,
                                                                        size: 8,
                                                                        color: Colors
                                                                            .amber,
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Icon(
                                                                            Icons.kitchen,
                                                                            size:
                                                                                18,
                                                                            color:
                                                                                whiteColor,
                                                                            shadows: [
                                                                              Shadow(blurRadius: 10, color: Colors.black)
                                                                            ],
                                                                          ),
                                                                          Text(
                                                                            r"6",
                                                                            style:
                                                                                const TextStyle(fontWeight: FontWeight.bold),
                                                                          )
                                                                        ],
                                                                      ),
                                                                      const Icon(
                                                                        Icons
                                                                            .circle,
                                                                        size: 8,
                                                                        color: Colors
                                                                            .red,
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Row(
                                                                            children: [
                                                                              Icon(
                                                                                Icons.bed_sharp,
                                                                                size: 10,
                                                                                color: whiteColor,
                                                                                shadows: [
                                                                                  Shadow(blurRadius: 10, color: Colors.black)
                                                                                ],
                                                                              ),
                                                                              Icon(
                                                                                Icons.bathroom_outlined,
                                                                                size: 10,
                                                                                color: whiteColor,
                                                                                shadows: [
                                                                                  Shadow(blurRadius: 10, color: Colors.black)
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          Text(
                                                                            "3",
                                                                            style:
                                                                                const TextStyle(fontWeight: FontWeight.bold),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      4),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                "About: ${prop['title']}",
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                              Text(
                                                                  "Amount:Tsh ${prop['amount']}/= per month"),
                                                              Text(
                                                                  "Location: ${prop['street']}, ${prop['region']}"),
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            });
                                      })
                                : Center(
                                    child: Text(_propresult['msg']),
                                  )),
                  ],
                ),
              ))
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: greyColor,
          child: Icon(Icons.add),
          onPressed: () {
            if (_auth.currentUser == null) {
              AwesomeDialog(
                  context: context,
                  dialogType: DialogType.error,
                  title: "Info",
                  desc:
                      "To upload property you need to have account and login with it,\n Do you wish to proceed?",
                  btnCancelText: "No",
                  btnOkText: "Yes",
                  btnCancelOnPress: () {},
                  btnOkOnPress: () {
                    CommonResponses()
                        .shiftPage(context, AuthenticationScreen());
                  }).show();
            } else {
              Navigator.push(
                  context,
                  PageTransition(
                      child: const PropertyUploadscreen(),
                      type: PageTransitionType.rightToLeft));
            }
          }),
    );
  }

  void _autherrorDialog() {
    showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: "logout_confirm",
        transitionDuration: Duration(seconds: 1),
        transitionBuilder: (context, anim1, anim2, child) {
          Animation<Offset> animation = Tween<Offset>(
                  begin: Offset(0, -(anim1.value * 0.4)), end: Offset(0, 0))
              .animate(anim1);
          return SlideTransition(
            position: animation,
            child: child,
          );
        },
        pageBuilder: (context, anim1, anim2) {
          return AlertDialog(
            title: Text("Confirm"),
            content: Text(
                "Dear ${_provider!.currentUser['first_name']}, Are you sure you want to logout?"),
            actions: [
              FilledButton.icon(
                  onPressed: () async {
                    CommonResponses().showLoadingDialog(context);
                    await _auth.signOut().then((value) {
                      CommonResponses()
                          .shiftPage(context, HomeScreen(), kill: true);
                    });
                  },
                  icon: Icon(Icons.thumb_up),
                  label: Text("Yes")),
              FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.back_hand),
                  label: Text("No"))
            ],
          );
        });
  }
}
