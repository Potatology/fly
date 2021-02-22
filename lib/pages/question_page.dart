import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

class QuestionPage extends StatefulWidget {
  @override
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  double _tweenEndValue = 1;

  @override
  Widget build(BuildContext context) {
    final textButton = RichText(
      text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: <TextSpan>[
            TextSpan(text: 'WHERE WOULD'),
            TextSpan(
                text: ' YOU', style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: ' FLY?')
          ]),
    );

    return TweenAnimationBuilder(
        tween: Tween<double>(begin: 0.5, end: _tweenEndValue),
        curve: Curves.easeIn,
        duration: Duration(milliseconds: 650),
        onEnd: () {
          setState(() {
            _tweenEndValue = _tweenEndValue == 1 ? 0.2 : 1;
          });
        },
        builder: (_, double opacity, __) {
          return Opacity(
            opacity: opacity,
            child: textButton,
          );
        });
  }
}
