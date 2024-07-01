import 'dart:io';

import 'package:arms/screens/full_screens/home_screen.dart';
import 'package:arms/screens/full_screens/panorama_capture_screen.dart';
import 'package:arms/screens/full_screens/panorama_view_init.dart';
import 'package:arms/services/common_responses.dart';
import 'package:arms/services/common_variables.dart';
import 'package:arms/services/database_services.dart';
import 'package:arms/services/modal_services.dart';
import 'package:camera_360/camera_360.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:number_selection/number_selection.dart';
import 'package:panorama_viewer/panorama_viewer.dart';

class PropertyUploadscreen extends StatefulWidget {
  const PropertyUploadscreen({super.key});

  @override
  State<PropertyUploadscreen> createState() => _PropertyUploadscreenState();
}

class _PropertyUploadscreenState extends State<PropertyUploadscreen> {
  final _pageController = PageController();
  final _auth = FirebaseAuth.instance;
  Map<String, dynamic> propertyData = {};
  Map<String, dynamic> _propertylocation = {};
  int _currentPage = 0;
  bool _hasFens = false;
  bool _hasParking = false;
  String _bedRoomCount = "1";
  String _storeRoomCount = "0";
  String _bathRoomCount = "0";
  String _kitchenRoomCount = "0";
  String _selfContBedRoomCount = "0";
  String _sittingRoomCount = "0";
  String _diningRoomCount = "0";

  String _selectedApSize = "Select";
  String _selectedApType = "Select";
  String _selectedApStatus = "Select";

  String _selectedPaymentPeriod = "Period";
  String _selectedOperation = "";
  TextEditingController _titleController = TextEditingController();
  TextEditingController _surfaceAreaController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _priceController = TextEditingController();

  List _images = [];
  List<Map<String, dynamic>> _image_3d = [];

  final DatabaseReference _districtsRef =
      FirebaseDatabase.instance.reference().child("DISTRICTS");
  final DatabaseReference _regionsRef =
      FirebaseDatabase.instance.reference().child("REGIONS");
  // SharedPreferences? _filterPref;
  Region? _selectedRegion;
  District? _selectedDistrict;
  TextEditingController _streetController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        bool backPage;
        if (_currentPage == 1) {
          _pageController.previousPage(
              duration: Duration(milliseconds: 500), curve: Curves.decelerate);
          backPage = false;
        } else {
          backPage = true;
        }
        return await backPage;
      },
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: whiteColor,
          backgroundColor: appColor,
          title: const Text("Upload property"),
        ),
        body: Stack(
          children: [
            StatefulBuilder(builder: (context, stateSetter) {
              return Container();
              // return PageView(
              //   controller: _pageController,
              //   physics: const NeverScrollableScrollPhysics(),
              //   onPageChanged: (page) {
              //     _currentPage = page;
              //   },
              //   children: [
              //     Container(
              //       margin: EdgeInsets.all(2),
              //       child: Column(
              //         children: [
              //           Row(
              //             children: [
              //               CircleAvatar(
              //                 radius: 12,
              //                 backgroundColor: greyColor,
              //                 child: Text("1"),
              //               ),
              //               SizedBox(
              //                 width: 3,
              //               ),
              //               Text(
              //                 "Propery info:",
              //                 style: TextStyle(
              //                     fontWeight: FontWeight.bold, fontSize: 17),
              //               ),
              //             ],
              //           ),
              //           Expanded(
              //               child: SingleChildScrollView(
              //             child: Column(
              //               children: [
              //                 Column(
              //                   crossAxisAlignment: CrossAxisAlignment.start,
              //                   children: [
              //                     const Text(
              //                       "Operation",
              //                       style:
              //                           TextStyle(fontWeight: FontWeight.bold),
              //                     ),
              //                     Container(
              //                         padding: EdgeInsets.all(0),
              //                         decoration: BoxDecoration(
              //                             borderRadius:
              //                                 BorderRadius.circular(5),
              //                             border: Border.all()),
              //                         child: RadioGroup<String>.builder(
              //                             groupValue: _selectedOperation,
              //                             // activeColor: kDominantColor,
              //                             onChanged: (val) {
              //                               setState(() {
              //                                 _selectedOperation =
              //                                     val.toString();
              //                               });
              //                             },
              //                             items: operation,
              //                             itemBuilder: (item) =>
              //                                 RadioButtonBuilder(item))),
              //                   ],
              //                 ),
              //                 SizedBox(
              //                   height: 5,
              //                 ),
              //                 Column(
              //                   crossAxisAlignment: CrossAxisAlignment.start,
              //                   children: [
              //                     Text(
              //                       "Title",
              //                       style:
              //                           TextStyle(fontWeight: FontWeight.bold),
              //                     ),
              //                     SizedBox(
              //                       height: 40,
              //                       child: TextFormField(
              //                         controller: _titleController,
              //                         decoration: const InputDecoration(
              //                             enabledBorder: OutlineInputBorder(),
              //                             contentPadding: EdgeInsets.symmetric(
              //                                 horizontal: 10, vertical: 10),
              //                             hintText:
              //                                 "write here eg Six room apartment",
              //                             border: OutlineInputBorder(
              //                               borderRadius: BorderRadius.only(
              //                                 topLeft: Radius.circular(-1),
              //                                 bottomLeft: Radius.circular(-1),
              //                               ),
              //                             )),
              //                       ),
              //                     ),
              //                   ],
              //                 ),
              //                 SizedBox(
              //                   height: 5,
              //                 ),
              //                 Column(
              //                   crossAxisAlignment: CrossAxisAlignment.stretch,
              //                   children: [
              //                     Text(
              //                       "Apartment type",
              //                       style:
              //                           TextStyle(fontWeight: FontWeight.bold),
              //                     ),
              //                     Container(
              //                       height: 40,
              //                       decoration: BoxDecoration(
              //                           borderRadius: BorderRadius.circular(5),
              //                           border: Border.all()),
              //                       child: DropdownButtonHideUnderline(
              //                         child: DropdownButton2(
              //                             onChanged: (val) {
              //                               FocusScopeNode currentScope =
              //                                   FocusScope.of(context);
              //                               if (!currentScope.hasPrimaryFocus) {
              //                                 currentScope.unfocus();
              //                               }
              //                               setState(() {
              //                                 _selectedApType = val.toString();
              //                               });
              //                             },
              //                             hint: Text(_selectedApType),
              //                             items: propertyType
              //                                 .map((e) => DropdownMenuItem(
              //                                     value: e,
              //                                     child: Text(e.toString())))
              //                                 .toList()),
              //                       ),
              //                     ),
              //                   ],
              //                 ),
              //                 SizedBox(
              //                   height: 5,
              //                 ),
              //                 Column(
              //                   crossAxisAlignment: CrossAxisAlignment.stretch,
              //                   children: [
              //                     Text(
              //                       "Apartment Size",
              //                       style:
              //                           TextStyle(fontWeight: FontWeight.bold),
              //                     ),
              //                     Container(
              //                       height: 40,
              //                       decoration: BoxDecoration(
              //                           borderRadius: BorderRadius.circular(5),
              //                           border: Border.all()),
              //                       child: DropdownButtonHideUnderline(
              //                         child: DropdownButton2(
              //                             onChanged: (val) {
              //                               FocusScopeNode currentScope =
              //                                   FocusScope.of(context);
              //                               if (!currentScope.hasPrimaryFocus) {
              //                                 currentScope.unfocus();
              //                               }
              //                               setState(() {
              //                                 _selectedApSize = val.toString();
              //                               });
              //                             },
              //                             hint: Text(_selectedApSize),
              //                             items: apartmentSize
              //                                 .map((e) => DropdownMenuItem(
              //                                     value: e,
              //                                     child: Text(e.toString())))
              //                                 .toList()),
              //                       ),
              //                     ),
              //                   ],
              //                 ),
              //                 SizedBox(
              //                   height: 5,
              //                 ),
              //                 Column(
              //                   crossAxisAlignment: CrossAxisAlignment.stretch,
              //                   children: [
              //                     Text(
              //                       "Surface area covered",
              //                       style:
              //                           TextStyle(fontWeight: FontWeight.bold),
              //                     ),
              //                     SizedBox(
              //                       height: 40,
              //                       width:
              //                           MediaQuery.of(context).size.width * 0.6,
              //                       child: TextFormField(
              //                         keyboardType: TextInputType.number,
              //                         inputFormatters: [
              //                           FilteringTextInputFormatter.digitsOnly
              //                         ],
              //                         controller: _surfaceAreaController,
              //                         decoration: const InputDecoration(
              //                             enabledBorder: OutlineInputBorder(),
              //                             contentPadding: EdgeInsets.symmetric(
              //                                 horizontal: 10, vertical: 10),
              //                             hintText:
              //                                 "Surface area in square feet",
              //                             border: OutlineInputBorder(
              //                               borderRadius: BorderRadius.only(
              //                                 topLeft: Radius.circular(-1),
              //                                 bottomLeft: Radius.circular(-1),
              //                               ),
              //                             )),
              //                       ),
              //                     ),
              //                   ],
              //                 ),
              //                 SizedBox(
              //                   height: 5,
              //                 ),
              //                 Column(
              //                   crossAxisAlignment: CrossAxisAlignment.stretch,
              //                   children: [
              //                     Text(
              //                       "Apartment Status",
              //                       style:
              //                           TextStyle(fontWeight: FontWeight.bold),
              //                     ),
              //                     Container(
              //                       height: 40,
              //                       decoration: BoxDecoration(
              //                           borderRadius: BorderRadius.circular(5),
              //                           border: Border.all()),
              //                       child: DropdownButtonHideUnderline(
              //                         child: DropdownButton2(
              //                             onChanged: (val) {
              //                               FocusScopeNode currentScope =
              //                                   FocusScope.of(context);
              //                               if (!currentScope.hasPrimaryFocus) {
              //                                 currentScope.unfocus();
              //                               }

              //                               setState(() {
              //                                 _selectedApStatus =
              //                                     val.toString();
              //                               });
              //                             },
              //                             hint: Text(_selectedApStatus),
              //                             items: propertyStatus
              //                                 .map((e) => DropdownMenuItem(
              //                                     value: e,
              //                                     child: Text(e.toString())))
              //                                 .toList()),
              //                       ),
              //                     ),
              //                   ],
              //                 ),
              //                 SizedBox(
              //                   height: 5,
              //                 ),
              //                 Column(
              //                   crossAxisAlignment: CrossAxisAlignment.start,
              //                   children: [
              //                     Text(
              //                       "Number of rooms",
              //                       style:
              //                           TextStyle(fontWeight: FontWeight.bold),
              //                     ),
              //                     Container(
              //                       padding:
              //                           EdgeInsets.symmetric(horizontal: 3),
              //                       decoration: BoxDecoration(
              //                           borderRadius: BorderRadius.circular(7),
              //                           border: Border.all()),
              //                       child: Column(
              //                           crossAxisAlignment:
              //                               CrossAxisAlignment.start,
              //                           children: [
              //                             Padding(
              //                                 padding:
              //                                     const EdgeInsets.symmetric(
              //                                         vertical: 1),
              //                                 child: Row(
              //                                   children: [
              //                                     const Text("Bedrooms",
              //                                         style: TextStyle(
              //                                             fontWeight:
              //                                                 FontWeight.w400)),
              //                                     const Spacer(),
              //                                     SizedBox(
              //                                       height: 35,
              //                                       child: NumberSelection(
              //                                           initialValue: int.parse(
              //                                               _bedRoomCount),
              //                                           minValue: 1,
              //                                           onChanged: (newVal) {
              //                                             _bedRoomCount =
              //                                                 newVal.toString();
              //                                           }),
              //                                     ),
              //                                   ],
              //                                 )),
              //                             Padding(
              //                                 padding:
              //                                     const EdgeInsets.symmetric(
              //                                         vertical: 1),
              //                                 child: Row(
              //                                   children: [
              //                                     const Text("Sitting rooms",
              //                                         style: TextStyle(
              //                                             fontWeight:
              //                                                 FontWeight.w400)),
              //                                     const Spacer(),
              //                                     SizedBox(
              //                                       height: 35,
              //                                       child: NumberSelection(
              //                                           initialValue: int.parse(
              //                                               _sittingRoomCount),
              //                                           minValue: 0,
              //                                           onChanged: (newVal) {
              //                                             _sittingRoomCount =
              //                                                 newVal.toString();
              //                                           }),
              //                                     ),
              //                                   ],
              //                                 )),
              //                             Padding(
              //                                 padding:
              //                                     const EdgeInsets.symmetric(
              //                                         vertical: 1),
              //                                 child: Row(
              //                                   children: [
              //                                     const Text("Dining rooms",
              //                                         style: TextStyle(
              //                                             fontWeight:
              //                                                 FontWeight.w400)),
              //                                     const Spacer(),
              //                                     SizedBox(
              //                                       height: 35,
              //                                       child: NumberSelection(
              //                                           initialValue: int.parse(
              //                                               _diningRoomCount),
              //                                           minValue: 0,
              //                                           onChanged: (newVal) {
              //                                             _diningRoomCount =
              //                                                 newVal.toString();
              //                                           }),
              //                                     ),
              //                                   ],
              //                                 )),
              //                             Padding(
              //                                 padding:
              //                                     const EdgeInsets.symmetric(
              //                                         vertical: 1),
              //                                 child: Row(
              //                                   children: [
              //                                     const Text(
              //                                         "self contained rooms",
              //                                         style: TextStyle(
              //                                             fontWeight:
              //                                                 FontWeight.w400)),
              //                                     const Spacer(),
              //                                     SizedBox(
              //                                       height: 35,
              //                                       child: NumberSelection(
              //                                           initialValue: int.parse(
              //                                               _selfContBedRoomCount),
              //                                           minValue: 0,
              //                                           onChanged: (newVal) {
              //                                             _selfContBedRoomCount =
              //                                                 newVal.toString();
              //                                           }),
              //                                     ),
              //                                   ],
              //                                 )),
              //                             Padding(
              //                                 padding:
              //                                     const EdgeInsets.symmetric(
              //                                         vertical: 1),
              //                                 child: Row(
              //                                   children: [
              //                                     const Text("Kitchen rooms",
              //                                         style: TextStyle(
              //                                             fontWeight:
              //                                                 FontWeight.w400)),
              //                                     const Spacer(),
              //                                     SizedBox(
              //                                       height: 35,
              //                                       child: NumberSelection(
              //                                           initialValue: int.parse(
              //                                               _kitchenRoomCount),
              //                                           minValue: 0,
              //                                           onChanged: (newVal) {
              //                                             _kitchenRoomCount =
              //                                                 newVal.toString();
              //                                           }),
              //                                     ),
              //                                   ],
              //                                 )),
              //                             Padding(
              //                                 padding:
              //                                     const EdgeInsets.symmetric(
              //                                         vertical: 1),
              //                                 child: Row(
              //                                   children: [
              //                                     const Text("Store rooms",
              //                                         style: TextStyle(
              //                                             fontWeight:
              //                                                 FontWeight.w400)),
              //                                     const Spacer(),
              //                                     SizedBox(
              //                                       height: 35,
              //                                       child: NumberSelection(
              //                                           initialValue: int.parse(
              //                                               _storeRoomCount),
              //                                           minValue: 0,
              //                                           onChanged: (newVal) {
              //                                             _storeRoomCount =
              //                                                 newVal.toString();
              //                                           }),
              //                                     ),
              //                                   ],
              //                                 )),
              //                             Padding(
              //                                 padding:
              //                                     const EdgeInsets.symmetric(
              //                                         vertical: 1),
              //                                 child: Row(
              //                                   children: [
              //                                     const Text(
              //                                         "Bath/toilet rooms",
              //                                         style: TextStyle(
              //                                             fontWeight:
              //                                                 FontWeight.w400)),
              //                                     const Spacer(),
              //                                     SizedBox(
              //                                       height: 35,
              //                                       child: NumberSelection(
              //                                           initialValue: int.parse(
              //                                               _bathRoomCount),
              //                                           minValue: 0,
              //                                           onChanged: (newVal) {
              //                                             _bathRoomCount =
              //                                                 newVal.toString();
              //                                           }),
              //                                     ),
              //                                   ],
              //                                 )),
              //                           ]),
              //                     ),
              //                   ],
              //                 ),
              //                 SizedBox(
              //                   height: 5,
              //                 ),
              //                 Column(
              //                   crossAxisAlignment: CrossAxisAlignment.stretch,
              //                   children: [
              //                     Text("Description(optional)",
              //                         style: TextStyle(
              //                             fontWeight: FontWeight.bold)),
              //                     Container(
              //                       child: TextFormField(
              //                         minLines: 3,
              //                         maxLines: 3,
              //                         controller: _descriptionController,
              //                         decoration: InputDecoration(
              //                             contentPadding: EdgeInsets.symmetric(
              //                                 horizontal: 10, vertical: 10),
              //                             hintText: "Describe here",
              //                             border: OutlineInputBorder(
              //                                 borderRadius:
              //                                     BorderRadius.circular(5))),
              //                       ),
              //                     ),
              //                   ],
              //                 ),
              //                 SizedBox(
              //                   height: 5,
              //                 ),
              //                 Column(
              //                   crossAxisAlignment: CrossAxisAlignment.stretch,
              //                   children: [
              //                     Text("Amount",
              //                         style: TextStyle(
              //                             fontWeight: FontWeight.bold)),
              //                     Row(
              //                       children: [
              //                         SizedBox(
              //                           height: 40,
              //                           width: _selectedOperation == "For sale"
              //                               ? MediaQuery.of(context)
              //                                       .size
              //                                       .width -
              //                                   5
              //                               : MediaQuery.of(context)
              //                                       .size
              //                                       .width *
              //                                   0.6,
              //                           child: TextFormField(
              //                             keyboardType: TextInputType.number,
              //                             inputFormatters: [
              //                               FilteringTextInputFormatter
              //                                   .digitsOnly
              //                             ],
              //                             controller: _priceController,
              //                             decoration: const InputDecoration(
              //                                 enabledBorder:
              //                                     OutlineInputBorder(),
              //                                 contentPadding:
              //                                     EdgeInsets.symmetric(
              //                                         horizontal: 10,
              //                                         vertical: 10),
              //                                 hintText: "Apartment cost in Tsh",
              //                                 border: OutlineInputBorder(
              //                                   borderRadius: BorderRadius.only(
              //                                     topLeft: Radius.circular(-1),
              //                                     bottomLeft:
              //                                         Radius.circular(-1),
              //                                   ),
              //                                 )),
              //                           ),
              //                         ),
              //                         _selectedOperation == "For sale"
              //                             ? Container()
              //                             : Expanded(
              //                                 child: Container(
              //                                   height: 40,
              //                                   decoration: BoxDecoration(
              //                                       borderRadius:
              //                                           BorderRadius.circular(
              //                                               5),
              //                                       border: Border.all()),
              //                                   child:
              //                                       DropdownButtonHideUnderline(
              //                                     child: DropdownButton2(
              //                                         onChanged: (val) {
              //                                           FocusScopeNode
              //                                               currentScope =
              //                                               FocusScope.of(
              //                                                   context);
              //                                           if (!currentScope
              //                                               .hasPrimaryFocus) {
              //                                             currentScope
              //                                                 .unfocus();
              //                                           }

              //                                           setState(() {
              //                                             _selectedPaymentPeriod =
              //                                                 val.toString();
              //                                           });
              //                                         },
              //                                         hint: Text(
              //                                             _selectedPaymentPeriod),
              //                                         items: payPeriodChoices
              //                                             .map((e) =>
              //                                                 DropdownMenuItem(
              //                                                     value: e,
              //                                                     child: Text(e
              //                                                         .toString())))
              //                                             .toList()),
              //                                   ),
              //                                 ),
              //                               ),
              //                       ],
              //                     )
              //                   ],
              //                 ),
              //                 const SizedBox(
              //                   height: 70,
              //                 ),
              //               ],
              //             ),
              //           ))
              //         ],
              //       ),
              //     ),
              //     Container(
              //       margin: EdgeInsets.all(2),
              //       child: Column(
              //         children: [
              //           Row(
              //             children: [
              //               CircleAvatar(
              //                 radius: 12,
              //                 backgroundColor: greyColor,
              //                 child: Text("2"),
              //               ),
              //               SizedBox(
              //                 width: 3,
              //               ),
              //               Text(
              //                 "Propery image and location:",
              //                 style: TextStyle(
              //                     fontWeight: FontWeight.bold, fontSize: 17),
              //               ),
              //             ],
              //           ),
              //           Expanded(
              //               child: SingleChildScrollView(
              //             child: Column(
              //               crossAxisAlignment: CrossAxisAlignment.start,
              //               children: [
              //                 Column(
              //                   crossAxisAlignment: CrossAxisAlignment.start,
              //                   children: [
              //                     const Text(
              //                       "Images",
              //                       style:
              //                           TextStyle(fontWeight: FontWeight.bold),
              //                     ),
              //                     Stack(
              //                       alignment: Alignment.topCenter,
              //                       children: [
              //                         Container(
              //                           height: 150,
              //                           width: screenSize.width,
              //                           padding: EdgeInsets.all(0),
              //                           decoration: BoxDecoration(
              //                               borderRadius:
              //                                   BorderRadius.circular(5),
              //                               border: Border.all()),
              //                           child: SingleChildScrollView(
              //                             scrollDirection: Axis.horizontal,
              //                             child: Row(
              //                               children: [
              //                                 Stack(
              //                                   alignment: Alignment.center,
              //                                   children: [
              //                                     Container(
              //                                       color: greyColor,
              //                                       height: 150,
              //                                       width: (16 / 9) * 100,
              //                                       child: _images.length > 0
              //                                           ? Image.file(_images[0])
              //                                           : Container(),
              //                                     ),
              //                                     Text(
              //                                       "Cover photo",
              //                                       style: TextStyle(
              //                                           fontWeight:
              //                                               FontWeight.bold),
              //                                     )
              //                                   ],
              //                                 ),
              //                                 Row(
              //                                   children: _images.map((e) {
              //                                     return e == _images[0]
              //                                         ? Container()
              //                                         : Container(
              //                                             margin:
              //                                                 EdgeInsets.only(
              //                                                     right: 4),
              //                                             color: greenColor,
              //                                             width: (9 / 16) * 170,
              //                                             child: Image.file(e));
              //                                   }).toList(),
              //                                 )
              //                               ],
              //                             ),
              //                           ),
              //                         ),
              //                         IconButton.outlined(
              //                             style: ButtonStyle(
              //                                 backgroundColor:
              //                                     MaterialStateColor
              //                                         .resolveWith((states) =>
              //                                             whiteColor)),
              //                             onPressed: () async {
              //                               if (_images.length == 0) {
              //                                 var pickedFile = await ImagePicker
              //                                     .platform
              //                                     .pickImage(
              //                                         source:
              //                                             ImageSource.gallery);
              //                                 var cropedFile =
              //                                     await ImageCropper.platform
              //                                         .cropImage(
              //                                             sourcePath:
              //                                                 pickedFile!.path,
              //                                             aspectRatio:
              //                                                 CropAspectRatio(
              //                                                     ratioX: 16,
              //                                                     ratioY: 9));
              //                                 _images
              //                                     .add(File(cropedFile!.path));
              //                               } else {
              //                                 var pickedFiles =
              //                                     await ImagePicker.platform
              //                                         .pickMultiImage();
              //                                 pickedFiles!.forEach((fl) {
              //                                   _images.add(File(fl.path));
              //                                 });
              //                               }
              //                               setState(() {});
              //                             },
              //                             icon: Icon(Icons.add))
              //                       ],
              //                     ),
              //                   ],
              //                 ),
              //                 SizedBox(
              //                   height: 5,
              //                 ),
              //                 const Text(
              //                   "3D image",
              //                   style: TextStyle(fontWeight: FontWeight.bold),
              //                 ),
              //                 Center(
              //                   child: FilledButton.icon(
              //                       icon: Icon(Icons.video_camera_back_rounded),
              //                       onPressed: () async {
              //                         // var response = CommonResponses().shiftPage(
              //                         //     context, PanoramaCaptureScreen());
              //                         // print(response);

              //                         await ImagePicker()
              //                             .pickMultiImage()
              //                             .then((files) {
              //                           files.forEach((el) {
              //                             _image_3d.add({
              //                               'image': File(el.path),
              //                               'controller':
              //                                   TextEditingController()
              //                             });
              //                           });
              //                           setState(() {});
              //                         });
              //                       },
              //                       label: const Text("Capture")),
              //                 ),
              //                 SizedBox(
              //                   width: screenSize.width,
              //                   height: (9 / 16) * screenSize.width + 55,
              //                   child: _image_3d.isEmpty
              //                       ? const Center(
              //                           child: Text("No vr image selected"),
              //                         )
              //                       : ListView.builder(
              //                           itemCount: _image_3d.length,
              //                           scrollDirection: Axis.horizontal,
              //                           shrinkWrap: true,
              //                           itemBuilder: (context, ind) {
              //                             var data = _image_3d[ind];

              //                             return Container(
              //                               margin: EdgeInsets.only(bottom: 4),
              //                               width: 300,
              //                               child: Column(
              //                                 children: [
              //                                   GestureDetector(
              //                                     onTap: () {
              //                                       var dataD = {
              //                                         'controller':
              //                                             data['controller']
              //                                                 .text,
              //                                         'image': data['image']
              //                                       };
              //                                       CommonResponses().shiftPage(
              //                                           context,
              //                                           PanoramaViewInit(
              //                                               dataD));
              //                                     },
              //                                     child: AbsorbPointer(
              //                                       child: Container(
              //                                         height: (9 / 16) *
              //                                             screenSize.width,
              //                                         color: Colors.red,
              //                                         child: Image.file(
              //                                           data['image'],
              //                                           fit: BoxFit.cover,
              //                                         ),
              //                                       ),
              //                                     ),
              //                                   ),
              //                                   TextFormField(
              //                                     controller:
              //                                         data['controller'],
              //                                     decoration:
              //                                         const InputDecoration(
              //                                             enabledBorder:
              //                                                 OutlineInputBorder(),
              //                                             contentPadding:
              //                                                 EdgeInsets
              //                                                     .symmetric(
              //                                                         horizontal:
              //                                                             10,
              //                                                         vertical:
              //                                                             10),
              //                                             hintText:
              //                                                 "What is this location?",
              //                                             border:
              //                                                 OutlineInputBorder(
              //                                               borderRadius:
              //                                                   BorderRadius
              //                                                       .only(
              //                                                 topLeft: Radius
              //                                                     .circular(-1),
              //                                                 bottomLeft: Radius
              //                                                     .circular(-1),
              //                                               ),
              //                                             )),
              //                                   ),
              //                                 ],
              //                               ),
              //                             );
              //                           }),
              //                 ),
              //                 const Text(
              //                   "Location",
              //                   style: TextStyle(fontWeight: FontWeight.bold),
              //                 ),
              //                 Padding(
              //                   padding: const EdgeInsets.only(left: 20),
              //                   child: Column(
              //                     crossAxisAlignment: CrossAxisAlignment.start,
              //                     children: [
              //                       const Text("Region ",
              //                           style: TextStyle(
              //                               fontWeight: FontWeight.bold)),
              //                       GestureDetector(
              //                         onTap: () {
              //                           showRegionsOrDistrictsBottomsheet(
              //                               "regions", stateSetter);
              //                         },
              //                         child: AbsorbPointer(
              //                           child: Container(
              //                             height: 40,
              //                             decoration: BoxDecoration(
              //                                 borderRadius:
              //                                     BorderRadius.circular(10),
              //                                 border: Border.all(
              //                                     color: Colors.grey)),
              //                             padding: const EdgeInsets.symmetric(
              //                                 horizontal: 5),
              //                             child: Row(
              //                               children: [
              //                                 Text(_selectedRegion == null
              //                                     ? "Select region"
              //                                     : _selectedRegion!.name),
              //                                 const Spacer(),
              //                                 IconButton(
              //                                     onPressed: () {
              //                                       showRegionsOrDistrictsBottomsheet(
              //                                           "regions", stateSetter);
              //                                     },
              //                                     icon: const Icon(
              //                                         Icons.arrow_drop_down))
              //                               ],
              //                             ),
              //                           ),
              //                         ),
              //                       ),
              //                       const SizedBox(
              //                         height: 10,
              //                       ),
              //                       const Text("District",
              //                           style: TextStyle(
              //                               fontWeight: FontWeight.bold)),
              //                       GestureDetector(
              //                         onTap: () {
              //                           if (_selectedRegion != null) {
              //                             showRegionsOrDistrictsBottomsheet(
              //                                 "districts", stateSetter);
              //                           } else {
              //                             Fluttertoast.showToast(
              //                                 msg: "Select region first!!");
              //                           }
              //                         },
              //                         child: AbsorbPointer(
              //                           child: Container(
              //                             height: 40,
              //                             decoration: BoxDecoration(
              //                                 borderRadius:
              //                                     BorderRadius.circular(10),
              //                                 border: Border.all(
              //                                     color: Colors.grey)),
              //                             padding: const EdgeInsets.symmetric(
              //                                 horizontal: 5),
              //                             child: Row(
              //                               children: [
              //                                 Text(_selectedDistrict == null
              //                                     ? "Select district"
              //                                     : _selectedDistrict!.name),
              //                                 const Spacer(),
              //                                 IconButton(
              //                                     onPressed:
              //                                         _selectedRegion == null
              //                                             ? null
              //                                             : () {
              //                                                 showRegionsOrDistrictsBottomsheet(
              //                                                     "districts",
              //                                                     stateSetter);
              //                                               },
              //                                     icon: const Icon(
              //                                         Icons.arrow_drop_down))
              //                               ],
              //                             ),
              //                           ),
              //                         ),
              //                       ),
              //                       const SizedBox(height: 10),
              //                       const Text(
              //                         "Ward/street",
              //                         style: TextStyle(
              //                             fontWeight: FontWeight.bold),
              //                       ),
              //                       SizedBox(
              //                         height: 40,
              //                         child: TextFormField(
              //                           controller: _streetController,
              //                           decoration: const InputDecoration(
              //                               enabledBorder: OutlineInputBorder(),
              //                               contentPadding:
              //                                   EdgeInsets.symmetric(
              //                                       horizontal: 10,
              //                                       vertical: 10),
              //                               hintText:
              //                                   "write here eg kimara suka",
              //                               border: OutlineInputBorder(
              //                                 borderRadius: BorderRadius.only(
              //                                   topLeft: Radius.circular(-1),
              //                                   bottomLeft: Radius.circular(-1),
              //                                 ),
              //                               )),
              //                         ),
              //                       ),
              //                     ],
              //                   ),
              //                 ),
              //                 const SizedBox(
              //                   height: 70,
              //                 )
              //               ],
              //             ),
              //           ))
              //         ],
              //       ),
              //     ),
              //     Container(
              //       margin: EdgeInsets.all(2),
              //       child: Text("Propery images"),
              //     ),
              //   ],
              // );
            }),
            Positioned(
                bottom: 0,
                left: 0,
                child: IconButton(
                    onPressed: () async {
                      CommonResponses().showLocationLoadingDialog(context);
                      var res = await CommonResponses().getCurrentLocation();
                      Navigator.pop(context);
                      if (res != null) {
                        _propertylocation = {
                          'lat': res.latitude,
                          'long': res.longitude
                        };
                      }
                    },
                    style: IconButton.styleFrom(backgroundColor: greyColor),
                    icon: const Icon(
                      Icons.location_pin,
                      size: 30,
                    )))
          ],
        ),
        floatingActionButton: FloatingActionButton(
            backgroundColor: blueColor,
            onPressed: () async {
              if (_currentPage == 0) {
                // _pageController.animateToPage(1,
                //     duration: const Duration(milliseconds: 500),
                //     curve: Curves.decelerate);
                if (_selectedOperation.isNotEmpty &&
                    _titleController.text.trim().isNotEmpty &&
                    _selectedApType != "Select" &&
                    _selectedApSize != "Select" &&
                    _surfaceAreaController.text.trim().isNotEmpty &&
                    _selectedApStatus != "Select" &&
                    _descriptionController.text.trim().isNotEmpty &&
                    _priceController.text.trim().isNotEmpty) {
                  if (_propertylocation.isNotEmpty) {
                    propertyData = {
                      "operation": _selectedOperation,
                      "title": _titleController.text.trim(),
                      "type": _selectedApType,
                      "size": _selectedApSize,
                      "area": _surfaceAreaController.text.trim(),
                      "status": _selectedApStatus,
                      "badrooms": _bedRoomCount,
                      "sittingrooms": _sittingRoomCount,
                      "diningrooms": _diningRoomCount,
                      "selfrooms": _selfContBedRoomCount,
                      "kitchenrooms": _kitchenRoomCount,
                      "storerooms": _storeRoomCount,
                      "bathtoiletrooms": _bathRoomCount,
                      "description": _descriptionController.text.trim(),
                      "approval_status": 'Not approved',
                      "amount": _priceController.text.trim(),
                      "location": _propertylocation,
                      "active_status": "Active"
                    };
                    if (_selectedOperation == "For rent" &&
                        _selectedPaymentPeriod == "Period") {
                      CommonResponses()
                          .showToast("Select payment period!!", isError: true);
                    } else {
                      if (_selectedOperation == "For rent") {
                        propertyData['period'] = _selectedPaymentPeriod;
                      }
                      _pageController.animateToPage(1,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.decelerate);
                    }
                  } else {
                    CommonResponses()
                        .showToast("Propery location is needed", isError: true);
                  }
                } else {
                  CommonResponses()
                      .showToast("Please fill all details!!", isError: true);
                }
              } else {
                if (_images.isNotEmpty && _image_3d.isNotEmpty) {
                  bool allLabled = true;
                  _image_3d.forEach((el) {
                    if (el['controller'].text.toString().trim().isEmpty) {
                      allLabled = false;
                    }
                  });
                  if (allLabled == true) {
                    if (_selectedDistrict != null &&
                        _selectedRegion != null &&
                        _streetController.text.trim().isNotEmpty) {
                      List img3D = [];

                      for (var i = 0; i < _image_3d.length; i++) {
                        img3D.add({
                          'file': _image_3d[i]['image'],
                          'name':
                              _image_3d[i]['controller'].text.toString().trim()
                        });
                      }
                      propertyData['images'] = _images;
                      propertyData['images_3D'] = img3D;
                      propertyData['region'] = _selectedRegion!.name;
                      propertyData['district'] = _selectedDistrict!.name;
                      propertyData['street'] = _streetController.text.trim();
                      propertyData['ownerId'] = _auth.currentUser!.uid;
                      CommonResponses().showLoadingDialog(context);
                      var res =
                          await DatabaseServices().uploadProperty(propertyData);
                      Navigator.pop(context);
                      //print(res['msg']);
                      if (res['msg'] == "done") {
                        CommonResponses().showToast("Uploaded successful..");
                        CommonResponses()
                            .shiftPage(context, HomeScreen(), kill: true);
                      } else {
                        CommonResponses().showToast(res['msg'], isError: true);
                      }
                    } else {
                      CommonResponses().showToast(
                          "Please enter location details of your apartment",
                          isError: true);
                    }
                  } else {
                    CommonResponses().showToast(
                        "Please name the place on all 3D images",
                        isError: true);
                  }
                } else {
                  //cognito devi
                  CommonResponses().showToast(
                      "Atleast one image and 3D image is needed!",
                      isError: true);
                }
              }
            },
            child: const Icon(
              Icons.arrow_right_alt,
              size: 30,
            )),
      ),
    );
  }

  void showRegionsOrDistrictsBottomsheet(
      String choice, Function(void Function()) stateSetter) {
    Size screenSize = MediaQuery.of(context).size;
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        )),
        builder: (context) {
          return Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            )),
            height: screenSize.height * 0.7,
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                      color: greyColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      )),
                  height: 40,
                  child: Center(
                      child: Text(
                    choice == "districts"
                        ? "Wilaya za ${_selectedRegion!.name.toString()}"
                        : "Mikoa ya Tanzania",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )),
                ),
                Expanded(
                  child: StreamBuilder(
                      stream: choice == "districts"
                          ? _districtsRef
                              .child("3")
                              .child(_selectedRegion!.id.toString())
                              .onValue
                          : _regionsRef.child("3").onValue,
                      builder: (context, AsyncSnapshot snap) {
                        if (snap.connectionState == ConnectionState.done ||
                            snap.connectionState == ConnectionState.active) {
                          if (snap.data != null) {
                            if (choice == "regions") {
                              regions.clear();
                            }
                            if (choice == "districts") {
                              districts.clear();
                            }
                            if (choice == "regions") {
                              for (int i = 0;
                                  i < snap.data!.snapshot.value.length;
                                  i++) {
                                var val = snap.data!.snapshot.value[i];
                                regions.add(Region(val["id"], val["name"],
                                    val["latitude"], val["longitude"]));
                              }
                            }
                            if (choice == "districts") {
                              snap.data!.snapshot.value.forEach((val) {
                                districts.add(District(val["id"], val["name"]));
                              });
                            }
                            return ListView.builder(
                                itemCount: choice == "districts"
                                    ? districts.length
                                    : regions.length,
                                itemBuilder: (context, index) {
                                  Region? thisRegion;
                                  District? thisDistrict;
                                  if (choice == "regions") {
                                    thisRegion = regions[index];
                                  }
                                  if (choice == "districts") {
                                    thisDistrict = districts[index];
                                  }
                                  return Container(
                                    margin: const EdgeInsets.only(top: 3),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            left: BorderSide(
                                                color: appColor, width: 5),
                                            right: BorderSide(
                                                color: appColor, width: 5))),
                                    child: ListTile(
                                      onTap: () {
                                        if (choice == "regions") {
                                          stateSetter(() {
                                            _selectedDistrict = null;
                                            // provider.propertyFilters[
                                            //     "district"] = null;
                                            // provider.propertyFilters[
                                            //     "districtName"] = null;
                                            _selectedRegion = thisRegion;
                                          });
                                          Navigator.pop(context);
                                          showRegionsOrDistrictsBottomsheet(
                                              "districts", stateSetter);
                                        }
                                        if (choice == "districts") {
                                          stateSetter(() {
                                            _selectedDistrict = thisDistrict;
                                          });
                                          Navigator.pop(context);
                                        }
                                      },
                                      dense: true,
                                      visualDensity:
                                          const VisualDensity(vertical: -3),
                                      title: Text(choice == "districts"
                                          ? thisDistrict!.name
                                          : thisRegion!.name),
                                    ),
                                  );
                                });
                          } else {
                            return CommonResponses().showLoadingDialog(context);
                          }
                        } else {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      }),
                ),
              ],
            ),
          );
        });
  }
}
