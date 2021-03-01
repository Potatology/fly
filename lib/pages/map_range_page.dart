import 'dart:async';
import 'package:blackfly/map_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapRangePage extends StatefulWidget {
  final PageController controller;
  MapRangePage({Key key, @required this.controller}) : super(key: key);

  @override
  _MapRangePageState createState() => _MapRangePageState();
}

class _MapRangePageState extends State<MapRangePage>
    with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;

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
  int _count;

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

  Future<void> _playAnimation() async {
    try {
      while (_count > 1) {
        await _controller.forward().orCancel;
        if (!_controller.isAnimating) {
          _controller.reset();
          _count--;
          setState(() {});
        }
        await _controller.forward().orCancel;
      }
    } on TickerCanceled {
      // the animation got canceled, probably because it was disposed of
    }
  }

  flyButtonCallBack() async {
    await _playAnimation();
    if (widget.controller.hasClients) {
      widget.controller.animateToPage(
        2,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _count = 5;
    mapMarkers = [];
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
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
                        padding: const EdgeInsets.only(top: 50.0),
                        child: Text('WITHIN $_minutes MIN FLIGHT'),
                      ),
                    ),
                    Positioned(
                      width: screenSize.width,
                      bottom: 150,
                      child: SizedBox(
                        height: screenSize.width,
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
                    Positioned(
                      width: screenSize.width,
                      bottom: 150,
                      child: SizedBox(
                        width: screenSize.width,
                        height: screenSize.width,
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
                      ),
                    ),
                    Positioned(
                      width: 300,
                      bottom: 80,
                      right: (screenSize.width - 300) / 2,
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
                        onPressed: () async {
                          await flyButtonCallBack();
                        },
                        child: Text('FLY'),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: ScaleTransition(
                        scale: _animation,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 80.0),
                          child: Text(
                            _count.toString(),
                            style:
                                TextStyle(fontSize: 300, color: Colors.white),
                          ),
                        ),
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
              child: Stack(
                children: [
                  OutlinedButton(
                    onPressed: () {
                      if (_permissionGranted == PermissionStatus.denied) {
                      } else {
                        _requestService();
                        _requestPermission();
                        setState(() {});
                      }
                    },
                    child: Text('LOCATE LAUNCH SITE'),
                  ),
                ],
              ),
            ),
          );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
