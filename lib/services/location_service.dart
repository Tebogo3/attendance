import 'package:attendance/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

class LocationService {
  Location location = Location();
  late LocationData _locData;

  Future<Map<String, dynamic>?> initializeAndGetLocation(
      BuildContext context) async {
    bool serviceEnabled;
    PermissionStatus persmissionGranted;

    // First check whether location is enabled or not in that device
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        Utils.showSnackBar("Please Enable Location Service", context);
        return null;
      }
    }
    // Check if service is enabled then ask permission for location from user
    persmissionGranted = await location.hasPermission();
    if (persmissionGranted == PermissionStatus.denied) {
      persmissionGranted = await location.requestPermission();
      if (persmissionGranted != PermissionStatus.granted) {
        Utils.showSnackBar("Please Allow Location Access", context);
        return null;
      }
    }

    //After permision is granted then return the cordinates
    _locData = await location.getLocation();
    return {'latitude': _locData.latitude, 'longitude': _locData.longitude};
  }
}
