import 'dart:async';
import 'package:blackfly/map_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapRangePage extends StatefulWidget {
  @override
  _MapRangePageState createState() => _MapRangePageState();
}

class _MapRangePageState extends State<MapRangePage> {
  final Location location = Location();
  PermissionStatus _permissionGranted;
  LocationData _locationData;
  String _error;
  bool _serviceEnabled;
  GoogleMapController mapController;
  LatLng _center;
  double _currentSliderValue = 40;
  int _minutes = 30;
  double _maxValue = 40;
  double _originalDiameter = 380;
  double _circleDiameter = 380;
  List<Marker> mapMarkers;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    controller.setMapStyle(mapStyleJson);
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

  Future<void> _requestService() async {
    if (_serviceEnabled == null || !_serviceEnabled) {
      final bool serviceRequestedResult = await location.requestService();
      _serviceEnabled = serviceRequestedResult;
      if (!serviceRequestedResult) {
        return;
      }
    }
  }

  Future<LocationData> _getLocation() async {
    _error = null;
    try {
      final LocationData _locationResult = await location.getLocation();
      _locationData = _locationResult;
    } on PlatformException catch (err) {
      _error = err.code;
    }
    _center = LatLng(_locationData.latitude, _locationData.longitude);
    return _locationData;
  }

  _onGMapTap(LatLng tappedCoord) {
    setState(() {
      mapMarkers = [];
      mapMarkers.add(Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(180),
        markerId: MarkerId(tappedCoord.toString()),
        position: tappedCoord,
      ));
    });
  }

  @override
  void initState() {
    mapMarkers = [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _permissionGranted == PermissionStatus.granted
        ? FutureBuilder(
            future: _getLocation(),
            builder: (context, snap) {
              Widget child;
              if (snap.hasData) {
                child = Stack(
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 60.0),
                        child: Text('WITHIN $_minutes MIN FLIGHT'),
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        height: 400,
                        child: GoogleMap(
                          markers: Set.from(mapMarkers),
                          onTap: _onGMapTap,
                          onMapCreated: _onMapCreated,
                          myLocationButtonEnabled: false,
                          mapType: MapType.normal,
                          myLocationEnabled: true,
                          initialCameraPosition: CameraPosition(
                            target: _center,
                            zoom: 8.85,
                          ),
                          onCameraMove: null,
                        ),
                      ),
                    ),
                    Center(
                        child: SizedBox(
                      width: 400,
                      height: 400,
                      child: Center(
                        child: Opacity(
                          opacity: 0.18,
                          child: IgnorePointer(
                            ignoring: true,
                            child: AnimatedContainer(
                              height: _circleDiameter,
                              width: _circleDiameter,
                              decoration: BoxDecoration(
                                  color: Colors.teal,
                                  borderRadius: BorderRadius.circular(200),
                                  border: Border.all(
                                      color: Colors.tealAccent, width: 10)),
                              duration: Duration(milliseconds: 250),
                            ),
                          ),
                        ),
                      ),
                    )),
                    Positioned(
                      width: 300,
                      bottom: 50,
                      right: 50,
                      child: Slider(
                          min: 0,
                          max: _maxValue,
                          divisions: 40,
                          activeColor: Colors.black87,
                          inactiveColor: Colors.black87,
                          value: _currentSliderValue,
                          onChanged: (value) {
                            setState(() {
                              _currentSliderValue = value;
                              _circleDiameter = _originalDiameter /
                                  (_maxValue / _currentSliderValue);
                              _minutes =
                                  (60 / (80 / _currentSliderValue)).floor();
                            });
                          }),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: OutlinedButton(
                        onPressed: () {},
                        child: Text('FLY'),
                      ),
                    )
                  ],
                );
              } else if (snap.hasError) {
                child = Text(_error);
              } else {
                child = CircularProgressIndicator();
              }
              return child;
            })
        : Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 100.0),
              child: OutlinedButton(
                onPressed: () {
                  if (_permissionGranted == PermissionStatus.denied) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                      'Enable location in Phone Settings',
                    )));
                  } else {
                    _requestService();
                    _requestPermission();
                    setState(() {});
                  }
                },
                child: Text('LOCATE LAUNCH SITE'),
              ),
            ),
          );
  }
}
