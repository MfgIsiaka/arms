import 'package:arms/screens/full_screens/apartment_details_screen.dart';
import 'package:arms/screens/full_screens/home_screen.dart';
import 'package:arms/services/common_responses.dart';
import 'package:arms/services/common_variables.dart';
import 'package:arms/services/database_services.dart';
import 'package:arms/services/provider_services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final _auth = FirebaseAuth.instance;
  Map<String, dynamic> _currentUser = {};
  Map<String, dynamic> _propresult = {};
  AppDataProvider? _provider;
  bool _loading = true;
  List _properties = [];

  Future<void> _getProperties() async {
    _propresult = {};
    var res = await DatabaseServices().retriveProperty("");
    setState(() {
      _loading = false;
      _propresult = res;
      _properties = _propresult['data'];
    });
  }

  @override
  void initState() {
    super.initState();
    _getProperties();
  }

  @override
  Widget build(BuildContext context) {
    _provider = Provider.of<AppDataProvider>(context);
    Size screenSize = MediaQuery.of(context).size;
    _currentUser = _provider!.currentUser;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Welcome Admin"),
        actions: [
          IconButton(
              onPressed: () {
                _showLogoutConfirmDialog();
              },
              icon: Icon(Icons.logout))
        ],
      ),
      body: _propresult.isEmpty || _loading
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
                  : StatefulBuilder(builder: (context, stateSetter) {
                      return ListView.builder(
                          itemCount: _properties.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> prop = _properties[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                        context,
                                        PageTransition(
                                            child: ApartmentDetailsScreen(prop),
                                            type:
                                                PageTransitionType.rightToLeft))
                                    .then((value) async {
                                  print('Calling');
                                  await _getProperties();
                                  setState(() {});
                                });
                              },
                              child: AbsorbPointer(
                                child: Container(
                                  margin: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color: whiteColor,
                                      boxShadow: [
                                        BoxShadow(
                                            color: blackColor, blurRadius: 2)
                                      ]),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10)),
                                        ),
                                        width: screenSize.width,
                                        height: (9 / 16) * screenSize.width,
                                        child: Stack(
                                          alignment: Alignment.topCenter,
                                          children: [
                                            Container(
                                              decoration: const BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(10),
                                                    topRight:
                                                        Radius.circular(10)),
                                              ),
                                              child: CachedNetworkImage(
                                                imageUrl: prop['images'][0],
                                                progressIndicatorBuilder:
                                                    (context, url, progress) =>
                                                        SpinKitCircle(
                                                  color: appColor,
                                                  size: 30,
                                                ),
                                                errorWidget:
                                                    (context, ss, child) {
                                                  return Container(
                                                    child: Icon(Icons.error),
                                                  );
                                                },
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 0,
                                              child: Container(
                                                width: screenSize.width,
                                                color: const Color.fromRGBO(
                                                    0, 0, 0, 0.5),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      color: blackColor,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 2),
                                                      child: Text(
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
                                                          size: 18,
                                                          color: whiteColor,
                                                          shadows: [
                                                            Shadow(
                                                                blurRadius: 10,
                                                                color: Colors
                                                                    .black)
                                                          ],
                                                        ),
                                                        Text(
                                                          "6",
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )
                                                      ],
                                                    ),
                                                    Icon(
                                                      Icons.circle,
                                                      size: 8,
                                                      color: Colors.red,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.dining_outlined,
                                                          size: 18,
                                                          color: whiteColor,
                                                          shadows: [
                                                            Shadow(
                                                                blurRadius: 10,
                                                                color: Colors
                                                                    .black)
                                                          ],
                                                        ),
                                                        Text(
                                                          "6",
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )
                                                      ],
                                                    ),
                                                    Icon(
                                                      Icons.circle,
                                                      size: 8,
                                                      color: appColor,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.chair,
                                                          size: 18,
                                                          color: whiteColor,
                                                          shadows: [
                                                            Shadow(
                                                                blurRadius: 10,
                                                                color: Colors
                                                                    .black)
                                                          ],
                                                        ),
                                                        Text(
                                                          "6",
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )
                                                      ],
                                                    ),
                                                    const Icon(
                                                      Icons.circle,
                                                      size: 8,
                                                      color: Colors.green,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .bathroom_outlined,
                                                          size: 18,
                                                          color: whiteColor,
                                                          shadows: [
                                                            Shadow(
                                                                blurRadius: 10,
                                                                color: Colors
                                                                    .black)
                                                          ],
                                                        ),
                                                        Text(
                                                          "6",
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )
                                                      ],
                                                    ),
                                                    const Icon(
                                                      Icons.circle,
                                                      size: 8,
                                                      color: Colors.amber,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.kitchen,
                                                          size: 18,
                                                          color: whiteColor,
                                                          shadows: [
                                                            Shadow(
                                                                blurRadius: 10,
                                                                color: Colors
                                                                    .black)
                                                          ],
                                                        ),
                                                        Text(
                                                          r"6",
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )
                                                      ],
                                                    ),
                                                    const Icon(
                                                      Icons.circle,
                                                      size: 8,
                                                      color: Colors.red,
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
                                                                Shadow(
                                                                    blurRadius:
                                                                        10,
                                                                    color: Colors
                                                                        .black)
                                                              ],
                                                            ),
                                                            Icon(
                                                              Icons
                                                                  .bathroom_outlined,
                                                              size: 10,
                                                              color: whiteColor,
                                                              shadows: [
                                                                Shadow(
                                                                    blurRadius:
                                                                        10,
                                                                    color: Colors
                                                                        .black)
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        Text(
                                                          "3",
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
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
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "About: ${prop['title']}",
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                                "Amount:Tsh ${prop['amount']}/= per month"),
                                            Row(
                                              children: [
                                                Text(
                                                    "Location: ${prop['street']}, ${prop['region']}"),
                                                Expanded(
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Text(
                                                      prop['approval_status'],
                                                      style: TextStyle(
                                                          color:
                                                              prop['approval_status'] ==
                                                                      'Approved'
                                                                  ? greenColor
                                                                  : redColor,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
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
                ),
    );
  }

  void _showLogoutConfirmDialog() {
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
                      _provider!.currentUser = {};
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
