import 'package:arms/services/common_responses.dart';
import 'package:arms/services/common_variables.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class MapScreen extends StatefulWidget {
  Map<String, dynamic> property;
  MapScreen(this.property, {super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GeoPoint? _propLocation;
  GeoPoint? _userLocation;
  Map<String, dynamic> _property = {};
  final _mapController =
      MapController(initMapWithUserPosition: const UserTrackingOption());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _property = widget.property;
    Future.delayed(const Duration(seconds: 1), () async {
      _propLocation = GeoPoint(
          latitude: _property['location']['lat'],
          longitude: _property['location']['long']);
      _mapController.addMarker(_propLocation!,
          markerIcon: const MarkerIcon(
            icon: Icon(
              Icons.location_pin,
              size: 40,
            ),
          ));
      _mapController.goToLocation(_propLocation!);
      double currentZoom = 4.0;
      double targetZoom = 13.0;
      double stepSize = 0.1;
      await Future.delayed(const Duration(milliseconds: 1000));
      for (double zoomLevel = currentZoom;
          zoomLevel <= targetZoom;
          zoomLevel += stepSize) {
        await _mapController.setZoom(zoomLevel: zoomLevel);
        await Future.delayed(const Duration(milliseconds: 5));
      }
      _mapController.goToLocation(_propLocation!);
      var position = await CommonResponses().getCurrentLocation();
      if (position != null) {
        _userLocation = GeoPoint(
            latitude: position.latitude, longitude: position.longitude);
        _mapController.addMarker(_userLocation!,
            markerIcon: const MarkerIcon(
              icon: Icon(
                Icons.location_pin,
                color: redColor,
                size: 40,
              ),
            ));
        _mapController.drawRoad(_userLocation!, _propLocation!,
            roadOption: RoadOption(roadColor: redColor));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OSMFlutter(
        controller: _mapController,
        osmOption: OSMOption(
          userTrackingOption: const UserTrackingOption(
            enableTracking: true,
            unFollowUser: false,
          ),
          zoomOption: const ZoomOption(
            initZoom: 8,
            minZoomLevel: 3,
            maxZoomLevel: 19,
            stepZoom: 1.0,
          ),
          userLocationMarker: UserLocationMaker(
            personMarker: const MarkerIcon(
              icon: Icon(
                Icons.location_history_rounded,
                color: Colors.red,
                size: 48,
              ),
            ),
            directionArrowMarker: const MarkerIcon(
              icon: Icon(
                Icons.double_arrow,
                size: 48,
              ),
            ),
          ),
          roadConfiguration: const RoadOption(
            roadColor: Colors.yellowAccent,
          ),
          markerOption: MarkerOption(
              defaultMarker: const MarkerIcon(
            icon: Icon(
              Icons.person_pin_circle,
              color: Colors.blue,
              size: 56,
            ),
          )),
        ),
      ),
    );
  }
}
