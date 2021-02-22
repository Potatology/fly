import 'package:flutter/cupertino.dart';

class Logo extends StatelessWidget {
  final width;

  Logo({double this.width = 100});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 80.42,
        width: width,
        child: Image.asset('assets/images/logo_300.jpg'));
  }
}
