import 'package:arms/screens/full_screens/map_screen.dart';
import 'package:arms/screens/full_screens/property_edit_screen.dart';
import 'package:arms/services/common_responses.dart';
import 'package:arms/services/common_variables.dart';
import 'package:arms/services/database_services.dart';
import 'package:arms/services/provider_services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:marquee/marquee.dart';
import 'package:page_transition/page_transition.dart';
import 'package:arms/screens/full_screens/virtual_tour_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ApartmentDetailsScreen extends StatefulWidget {
  Map<String, dynamic> prop;
  ApartmentDetailsScreen(this.prop, {super.key});

  @override
  State<ApartmentDetailsScreen> createState() => _ApartmentDetailsScreenState();
}

class _ApartmentDetailsScreenState extends State<ApartmentDetailsScreen> {
  final _mapController =
      MapController(initMapWithUserPosition: const UserTrackingOption());
  final _auth = FirebaseAuth.instance;
  Map<String, dynamic> _currentUser = {};
  Map<String, dynamic> _prop = {};
  Map<String, dynamic> _ownerdata = {};
  AppDataProvider? _provider;
  Map<String, dynamic> _propFromDb = {};

  Future<void> _getOwnerDetails() async {
    var res = await DatabaseServices().getSingleUser(_prop['ownerId']);
    setState(() {
      _ownerdata = res;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _prop = widget.prop;
    _getOwnerDetails();
    _getProperties();
  }

  @override
  Widget build(BuildContext context) {
    _provider = Provider.of<AppDataProvider>(context);
    Size screenSize = MediaQuery.of(context).size;
    _currentUser = _provider!.currentUser;
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: screenSize.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(border: Border(bottom: BorderSide())),
                child: Center(
                  child: Text(
                    "Details",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                        padding: EdgeInsets.symmetric(horizontal: 2),
                        color: appColor,
                        child: Text(
                          "Pictures",
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        )),
                    Container(
                      width: screenSize.width,
                      height: (9 / 16) * screenSize.width,
                      color: Color.fromARGB(158, 158, 158, 158),
                      child: PageView.builder(
                          itemCount: _prop['images'].length,
                          itemBuilder: (context, index) {
                            return Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                      right: BorderSide(
                                          color: appColor, width: 3))),
                              child: CachedNetworkImage(
                                imageUrl: _prop['images'][index],
                                progressIndicatorBuilder:
                                    (context, url, progress) => SpinKitCircle(
                                  color: appColor,
                                  size: 30,
                                ),
                                errorWidget: (context, ss, child) {
                                  return Container(
                                    child: Icon(Icons.error),
                                  );
                                },
                              ),
                            );
                          }),
                    )
                  ],
                ),
              ),
              Expanded(
                  child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  _launchCommunication(
                                      "tel:${_ownerdata['data']['phone']}");
                                },
                                style: IconButton.styleFrom(
                                    backgroundColor: redColor,
                                    foregroundColor: whiteColor),
                                icon: Icon(Icons.phone)),
                            IconButton(
                                onPressed: () {
                                  _launchCommunication(
                                      "sms:${_ownerdata['data']['phone']}?body='Ningependa kujua ikiwa nyumba hii bado unayo nimeipenda'");
                                },
                                style: IconButton.styleFrom(
                                    backgroundColor: Colors.blueGrey,
                                    foregroundColor: whiteColor),
                                icon: Icon(Icons.message)),
                            IconButton(
                                onPressed: () {
                                  _launchCommunication(
                                      "mailto:${_ownerdata['data']['email']}?body='Ningependa kujua ikiwa nyumba hii bado unayo nimeipenda'");
                                },
                                style: IconButton.styleFrom(
                                    backgroundColor: blueColor,
                                    foregroundColor: whiteColor),
                                icon: const Icon(Icons.email)),
                            _currentUser['role'] == "admin"
                                ? IconButton(
                                    onPressed: () {
                                      _showApprovalEditingDialog();
                                    },
                                    style: IconButton.styleFrom(
                                        backgroundColor: redColor,
                                        foregroundColor: whiteColor),
                                    icon: const Icon(Icons.edit))
                                : Container(),
                            (_auth.currentUser != null &&
                                    _prop['ownerId'] == _auth.currentUser!.uid)
                                ? IconButton(
                                    onPressed: () {
                                      _showeditDialog();
                                    },
                                    style: IconButton.styleFrom(
                                        backgroundColor: yellowColor,
                                        foregroundColor: blackColor),
                                    icon: const Icon(Icons.edit))
                                : Container(),
                          ],
                        ),
                        OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: blueColor,
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  PageTransition(
                                      child: VirtualToruScreen(_prop),
                                      type: PageTransitionType.rightToLeft));
                            },
                            icon: Icon(Icons.visibility),
                            label: Text("Virtual Tour")),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: 2),
                            color: appColor,
                            child: Text(
                              "Apartment",
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            )),
                        Container(
                            width: screenSize.width,
                            decoration: BoxDecoration(
                                border: Border.all(color: appColor)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  padding: const EdgeInsets.only(left: 3),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          left: BorderSide(
                                              width: 2, color: appColor))),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                            "ABOUT:",
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: greyColor,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Spacer(),
                                          _currentUser['role'] == 'admin'
                                              ? Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 5),
                                                  decoration: BoxDecoration(
                                                      border: Border.all()),
                                                  child: RichText(
                                                      text: TextSpan(
                                                          text:
                                                              'APPROVAL STATUS: ',
                                                          style: TextStyle(
                                                              color: blackColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                          children: <TextSpan>[
                                                        TextSpan(
                                                          text: _prop[
                                                              'approval_status'],
                                                          style: TextStyle(
                                                            color:
                                                                _prop['approval_status'] ==
                                                                        "Approved"
                                                                    ? greenColor
                                                                    : redColor,
                                                          ),
                                                        )
                                                      ])),
                                                )
                                              : Container(),
                                          _auth.currentUser != null &&
                                                  _prop['ownerId'] ==
                                                      _auth.currentUser!.uid
                                              ? Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 5),
                                                  decoration: BoxDecoration(
                                                      border: Border.all()),
                                                  child: RichText(
                                                      text: TextSpan(
                                                          text:
                                                              'ACTIVE STATUS: ',
                                                          style: TextStyle(
                                                              color: blackColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                          children: <TextSpan>[
                                                        TextSpan(
                                                          text: _prop[
                                                              'active_status'],
                                                          style: TextStyle(
                                                            color:
                                                                _prop['active_status'] ==
                                                                        "Active"
                                                                    ? greenColor
                                                                    : redColor,
                                                          ),
                                                        )
                                                      ])),
                                                )
                                              : Container(),
                                          const SizedBox(
                                            width: 10,
                                          )
                                        ],
                                      ),
                                      Text(
                                        _prop['title'],
                                        style: const TextStyle(fontSize: 16),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                SizedBox(
                                  height: 250,
                                  child: GridView(
                                    controller: ScrollController(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            childAspectRatio: 4 / 1,
                                            mainAxisSpacing: 3),
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.only(left: 3),
                                        decoration: BoxDecoration(
                                            border: Border(
                                                left: BorderSide(
                                                    width: 2,
                                                    color: appColor))),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "CATEGORY:",
                                              style: TextStyle(
                                                  color: greyColor,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              _prop['type'],
                                              style: TextStyle(fontSize: 16),
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.only(left: 3),
                                        decoration: BoxDecoration(
                                            border: Border(
                                                left: BorderSide(
                                                    width: 2,
                                                    color: appColor))),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "ACTION:",
                                              style: TextStyle(
                                                  color: greyColor,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              _prop['operation'],
                                              style: TextStyle(fontSize: 16),
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.only(left: 3),
                                        decoration: BoxDecoration(
                                            border: Border(
                                                left: BorderSide(
                                                    width: 2,
                                                    color: appColor))),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "STATUS:",
                                              style: TextStyle(
                                                  color: greyColor,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              _prop['status'],
                                              style: TextStyle(fontSize: 16),
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.only(left: 3),
                                        decoration: BoxDecoration(
                                            border: Border(
                                                left: BorderSide(
                                                    width: 2,
                                                    color: appColor))),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "SIZE:",
                                              style: TextStyle(
                                                  color: greyColor,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              _prop['size'],
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: 16),
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.only(left: 3),
                                        decoration: BoxDecoration(
                                            border: Border(
                                                left: BorderSide(
                                                    width: 2,
                                                    color: appColor))),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "BEDROOMS:",
                                              style: TextStyle(
                                                  color: greyColor,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              _prop['badrooms'],
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: 16),
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.only(left: 3),
                                        decoration: BoxDecoration(
                                            border: Border(
                                                left: BorderSide(
                                                    width: 2,
                                                    color: appColor))),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "BEDROOMS:",
                                              style: TextStyle(
                                                  color: greyColor,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              _prop['badrooms'],
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: 16),
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.only(left: 3),
                                        decoration: BoxDecoration(
                                            border: Border(
                                                left: BorderSide(
                                                    width: 2,
                                                    color: appColor))),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "SITTING ROOMS:",
                                              style: TextStyle(
                                                  color: greyColor,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              _prop['sittingrooms'],
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: 16),
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.only(left: 3),
                                        decoration: BoxDecoration(
                                            border: Border(
                                                left: BorderSide(
                                                    width: 2,
                                                    color: appColor))),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "DINING ROOMS:",
                                              style: TextStyle(
                                                  color: greyColor,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              _prop['diningrooms'],
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: 16),
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.only(left: 3),
                                        decoration: BoxDecoration(
                                            border: Border(
                                                left: BorderSide(
                                                    width: 2,
                                                    color: appColor))),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "SELF ROOMS:",
                                              style: TextStyle(
                                                  color: greyColor,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              _prop['selfrooms'],
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: 16),
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.only(left: 3),
                                        decoration: BoxDecoration(
                                            border: Border(
                                                left: BorderSide(
                                                    width: 2,
                                                    color: appColor))),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "KITCHEN ROOMS:",
                                              style: TextStyle(
                                                  color: greyColor,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              _prop['kitchenrooms'],
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: 16),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Container(
                                  padding: const EdgeInsets.only(left: 3),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          left: BorderSide(
                                              width: 2, color: appColor))),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "PRICE:",
                                            style: TextStyle(
                                                color: greyColor,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            _prop['operation'] == "For rent"
                                                ? "TSH ${_prop['amount']}/= per ${_prop['period'].toString().substring(1)}"
                                                : "TSH ${_prop['amount']}/=",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: appColor),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Container(
                                  padding: const EdgeInsets.only(left: 3),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          left: BorderSide(
                                              width: 2, color: appColor))),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "LOCATION:",
                                              style: TextStyle(
                                                  color: greyColor,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(
                                              //width: 100,
                                              height: 30,
                                              child: Marquee(
                                                text:
                                                    "${_prop['street']}, ${_prop['district']} ${_prop['region']}",
                                                style: const TextStyle(
                                                    fontSize: 16),
                                                blankSpace:
                                                    screenSize.width * 0.7,
                                                startAfter:
                                                    const Duration(seconds: 1),
                                                pauseAfterRound:
                                                    const Duration(seconds: 1),
                                                numberOfRounds: 2,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Container(
                                  padding: const EdgeInsets.only(left: 3),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          left: BorderSide(
                                              width: 2, color: appColor))),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "DESCRIPTION:",
                                        style: TextStyle(
                                            color: greyColor,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        _prop['description'],
                                        maxLines: 4,
                                        style: TextStyle(fontSize: 16),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                              ],
                            ))
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            color: appColor,
                            child: const Text(
                              "Agent",
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            )),
                        Container(
                            width: screenSize.width,
                            padding: const EdgeInsets.only(left: 3),
                            decoration: BoxDecoration(
                                border: Border.all(color: appColor)),
                            child: _ownerdata.isEmpty
                                ? Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : ListTile(
                                    contentPadding: const EdgeInsets.only(
                                        left: 1, top: 0, bottom: 0),
                                    leading: Container(
                                      margin: const EdgeInsets.only(right: 5),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 3),
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                          color: whiteColor,
                                          boxShadow: [
                                            BoxShadow(
                                                blurRadius: 4.4,
                                                color: blackColor)
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          image: DecorationImage(
                                            fit: BoxFit.contain,
                                            image: NetworkImage(
                                              _ownerdata['data']
                                                  ['profile_photo'],
                                            ),
                                          )),
                                    ),
                                    title: Text(
                                      "${_ownerdata['data']['first_name']} ${_ownerdata['data']['last_name']}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      "${_ownerdata['data']['phone']} - ${_ownerdata['data']['email']}",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            color: appColor,
                            child: const Text(
                              "Street Map",
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            )),
                        Container(
                            width: screenSize.width,
                            padding: const EdgeInsets.only(left: 3),
                            decoration: BoxDecoration(
                                border: Border.all(color: appColor)),
                            child: ElevatedButton(
                                onPressed: () {
                                  CommonResponses()
                                      .shiftPage(context, MapScreen(_prop));
                                },
                                child: const Text("Open street map"))),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _getProperties() async {
    _propFromDb = {};
    var res = await DatabaseServices().retriveProperty("");
    setState(() {
      List data = res['data'];
      int ind = data.indexWhere((el) => el['id'] == _prop['id']);
      _prop = data[ind];
      //print(_propFromDb);
    });
  }

  void _launchCommunication(String uri) async {
    if (await canLaunch(uri)) {
      await launch(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }

  void _showApprovalEditingDialog() {
    showGeneralDialog(
        context: context,
        pageBuilder: (cont, anim1, anim2) {
          return AlertDialog(
            titlePadding: EdgeInsets.all(0),
            title: const Center(
              child: Text(
                "Update status",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _prop['approval_status'] == "Approved"
                      ? 'This property is now active, meaning people can still view it and contact seller.'
                      : 'This property is not approved, thus people are now unable to see it.',
                  textAlign: TextAlign.center,
                ),
                ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(cont);
                      CommonResponses().showLoadingDialog(context);
                      String newStatus = "";
                      if (_prop['approval_status'] == "Approved") {
                        newStatus = "Not approved";
                      } else {
                        newStatus = "Approved";
                      }
                      var res = await DatabaseServices()
                          .updatePropertyApprovalStatus(_prop['id'], newStatus);
                      if (res['msg'] == 'done') {
                        await _getProperties();
                        CommonResponses()
                            .showToast("Status updated successfuy..");
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: appColor, foregroundColor: whiteColor),
                    child: Text(_prop['approval_status'] == "Active"
                        ? 'Change to Rejected'
                        : 'Change to Approved'))
              ],
            ),
          );
        });
  }

  void _showeditDialog() {
    showGeneralDialog(
        context: context,
        pageBuilder: (cont, anim1, anim2) {
          return AlertDialog(
            titlePadding: EdgeInsets.all(0),
            title: const Center(
              child: Text(
                "Update status",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _prop['active_status'] == "Active"
                      ? 'This property is now active, meaning people can still view it and contact you.'
                      : 'this property is already sold, thus people are now unable to see it.',
                  textAlign: TextAlign.center,
                ),
                ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(cont);
                      CommonResponses().showLoadingDialog(context);
                      String newStatus = "";
                      if (_prop['active_status'] == "Active") {
                        newStatus = "Rented";
                      } else {
                        newStatus = "Active";
                      }
                      var res = await DatabaseServices()
                          .updatePropertyInfo(_prop['id'], newStatus);
                      if (res['msg'] == 'done') {
                        await _getProperties();
                        CommonResponses()
                            .showToast("Status updated successfuy..");
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: appColor, foregroundColor: whiteColor),
                    child: Text(_prop['active_status'] == "Active"
                        ? 'Change to rented'
                        : 'Change to active'))
              ],
            ),
          );
        });
  }
}
