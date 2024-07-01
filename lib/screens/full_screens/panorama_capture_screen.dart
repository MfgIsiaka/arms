import 'package:arms/services/common_responses.dart';
import 'package:flutter/material.dart';
import 'package:camera_360/camera_360.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

class PanoramaCaptureScreen extends StatefulWidget {
  const PanoramaCaptureScreen({super.key});

  @override
  State<PanoramaCaptureScreen> createState() => _PanoramaCaptureScreenState();
}

class _PanoramaCaptureScreenState extends State<PanoramaCaptureScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Camera360(
      // Text shown while panorama image is being prepared
      userLoadingText: "Preparing panorama...",
      // Text shown on while taking the first image
      userHelperText: "Point the camera at the dot",
      // Text shown when user should tilt the device to the left
      userHelperTiltLeftText: "Tilt left",
      // Text shown when user should tilt the device to the right
      userHelperTiltRightText: "Tilt Right",
      // Suggested key for iPhone >= 11 is 2 to select the wide-angle camera
      // On android devices 0 is suggested as at the moment Camera switchingis not possible on android
      userSelectedCameraKey: 2,
      // Camera selector Visibilitiy
      cameraSelectorShow: true,
      // Camera selector Info Visibilitiy
      cameraSelectorInfoPopUpShow: true,
      // Camera selector Info Widget
      cameraSelectorInfoPopUpContent: const Text(
        "Select the camera with the widest viewing angle below.",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xffEFEFEF),
        ),
      ),
      // Callback function called when 360 capture ended
      onCaptureEnded: (data) {
        // Returned data will be a map like below
        //{
        //  'success': true or false
        //  'panorama': XFile or null,
        //  'options': {
        //    'selected_camera': int KEY,
        //    'vertical_camera_angle': int DEG,
        //  }
        //}
        if (data['success'] == true) {
          XFile panorama = data['panorama'];
          print("Final image returned $panorama.toString()");
        } else {
          print("Final image failed");
        }
      },
      // Callback function called when the camera lens is changed
      onCameraChanged: (cameraKey) {
        print("Camera changed ${cameraKey.toString()}");
      },
      // Callback function called when capture progress is changed
      onProgressChanged: (newProgressPercentage) {
        CommonResponses().showToast("Progress changed: $newProgressPercentage");
      },
    ));
  }
}
