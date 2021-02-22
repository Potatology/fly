import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';

class MapRangePage extends StatefulWidget {
  @override
  _MapRangePageState createState() => _MapRangePageState();
}

class _MapRangePageState extends State<MapRangePage> {
  Location location = new Location();
  LocationData _location;
  PermissionStatus _permissionGranted;
  String _error;

  Future<PermissionStatus> _checkPermissions() async {
    final PermissionStatus permissionGrantedResult =
        await location.hasPermission();
    setState(() {
      _permissionGranted = permissionGrantedResult;
    });
    return _permissionGranted;
  }

  Future<void> _requestPermission() async {
    if (_permissionGranted != PermissionStatus.granted) {
      final PermissionStatus permissionRequestedResult =
          await location.requestPermission();
      setState(() {
        _permissionGranted = permissionRequestedResult;
      });
    }
  }

  Future<void> _getLocation() async {
    setState(() {
      _error = null;
    });
    try {
      final LocationData _locationResult = await location.getLocation();
      setState(() {
        _location = _locationResult;
      });
    } on PlatformException catch (err) {
      setState(() {
        _error = err.code;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locateLaunchsiteButton = OutlinedButton(
        onPressed: () {
          //_requestPermission();
        },
        child: Text('LOCATE LAUNCH SITE'));

    final locationText = FutureBuilder(
        future: _getLocation(),
        builder: (context, snapshot) {
          return _location == null ? Text('no location') : Text('$_location');
        });

    return Container(
      height: 300,
      width: 300,
      child: FutureBuilder(
        future: _checkPermissions(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          Widget child;
          if (snapshot.hasData) {
            child = _permissionGranted == PermissionStatus.granted
                ? locationText
                : locateLaunchsiteButton;
          } else if (snapshot.hasError) {
            child = Text('$snapshot.error');
          } else {
            child = SizedBox(
              height: 60,
              width: 60,
              child: CircularProgressIndicator(
                backgroundColor: Colors.black,
              ),
            );
          }
          return Center(
            child: child,
          );
        },
      ),
    );
  }
}
