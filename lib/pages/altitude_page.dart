import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AltitudePage extends StatefulWidget {
  final PageController controller;

  AltitudePage({Key key, @required this.controller}) : super(key: key);

  @override
  _AltitudePageState createState() => _AltitudePageState();
}

class _AltitudePageState extends State<AltitudePage> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  double _crosshairY = 320.0;
  bool _showAirCraft;
  double _tweenEndValue = 1;

  @override
  void initState() {
    super.initState();
    _showAirCraft = false;
  }

  void _onHashmarksTap(TapDownDetails details) {}

  void _onDragUpdate(DragUpdateDetails dragUpdateDetails) {
    if (dragUpdateDetails.primaryDelta < 0) {
      setState(() {
        if (_crosshairY < 400) {
          _crosshairY += 5;
        }
      });
    } else if (dragUpdateDetails.primaryDelta > 0) {
      if (_crosshairY > 240) {
        _crosshairY -= 5;
      }
    }
  }

  void _onDragEnd(DragEndDetails dragEndDetails) {}

  @override
  Widget build(BuildContext context) {
    Size _screensize = MediaQuery.of(context).size;

    final crosshair = Container(
      height: 20,
      width: 200,
      child: Image.asset('assets/images/crosshair.png'),
    );
    final hashmarks = Container(
      height: 170,
      child: Image.asset('assets/images/hashmarks.png'),
    );

    List<Widget> children = [];
    children = _showAirCraft
        ? [
            Center(
              child: Image.asset('assets/images/aircraft.png'),
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 100.0),
                  child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (BuildContext context) {
                          return Scaffold(
                            body: const WebView(
                              initialUrl: 'https://opener.aero/#technology',
                              javascriptMode: JavascriptMode.unrestricted,
                            ),
                          );
                        }));
                      },
                      child: Text('LEARN MORE')),
                ))
          ]
        : [
            Padding(
              padding: const EdgeInsets.only(top: 150.0),
              child: Align(
                alignment: Alignment.topCenter,
                child: Offstage(
                  offstage: _crosshairY < 350 ? true : false,
                  child: TweenAnimationBuilder(
                    duration: Duration(milliseconds: 550),
                    tween: Tween<double>(begin: 0.5, end: _tweenEndValue),
                    curve: Curves.easeIn,
                    onEnd: () {
                      setState(() {
                        _tweenEndValue = _tweenEndValue == 1 ? 0.2 : 1;
                      });
                    },
                    builder: (_, opacity, __) {
                      return Opacity(
                        opacity: opacity,
                        child: Text(
                          'GAIN ELEVATION',
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            AnimatedPositioned(
                onEnd: () {
                  if (_crosshairY <= 240) {
                    _showAirCraft = true;
                    setState(() {});
                  }
                },
                duration: Duration(milliseconds: 1000),
                curve: Curves.easeIn,
                left: (_screensize.width - 200) / 2,
                top: _crosshairY,
                child: crosshair),
            Center(child: hashmarks),
            Center(
              child: SizedBox(
                  height: 170,
                  width: _screensize.width - 40,
                  child: Center(
                    child: SizedBox(
                      height: 170,
                      child: GestureDetector(
                        onTapDown: _onHashmarksTap,
                        onVerticalDragUpdate: _onDragUpdate,
                        onVerticalDragEnd: _onDragEnd,
                      ),
                    ),
                  )
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     OutlinedButton(
                  //         onPressed: () {
                  //           setState(() {
                  //             print(_crosshairY.toString());
                  //             if (_crosshairY > 240)
                  //               _crosshairY = _crosshairY - 40;
                  //           });
                  //         },
                  //         child: Text('UP')),
                  //     OutlinedButton(
                  //         onPressed: () {
                  //           print(_crosshairY.toString());
                  //           setState(() {
                  //             if (_crosshairY < 400)
                  //               _crosshairY = _crosshairY + 40;
                  //           });
                  //         },
                  //         child: Text('DOWN')),
                  //   ],
                  // ),
                  ),
            ),
          ];

    return Container(
      width: _screensize.width,
      height: _screensize.width,
      child: Stack(
        children: children,
      ),
    );
  }
}
