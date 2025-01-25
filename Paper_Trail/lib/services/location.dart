import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationService{
  late Location _location;
  bool _serviceEnabled = false;
  PermissionStatus? _grantedPermission;

  LocationService(){
    _location = Location();
  }

  /// Checks if the user has granted location access to the app.
  Future<bool> _checkPermission() async {
    if(await _checkService()){
      _grantedPermission = await _location.hasPermission();
      if(_grantedPermission == PermissionStatus.denied){
        _grantedPermission = await _location.requestPermission();
      }
    }
    return _grantedPermission == PermissionStatus.granted;
  }

  /// Checks if location services are enabled on the device
  Future<bool> _checkService() async {
    try{
      _serviceEnabled = await _location.serviceEnabled();
      if(!_serviceEnabled){
        _serviceEnabled = await _location.requestService();
      }
    } on PlatformException catch(e){
      debugPrint("${e.code}: ${e.message}\n${e.details}\n${e.stacktrace}");
      _serviceEnabled = false;
      await _checkService();
    }
    return _serviceEnabled;
  }

  /// Gets the users current location
  Future<LocationData?> getLocation() async {
    if(await _checkPermission()){
      final locationData = _location.getLocation();
      return locationData;
    }
    return null;
  }

  /// Opens google maps at the coordinates provided as input parameters
  void openGoogleMaps(double lat, double lon) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lon';
    launchUrl(Uri.parse(url));
  }
}
