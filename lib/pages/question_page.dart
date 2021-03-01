import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class QuestionPage extends StatefulWidget {
  final PageController controller;

  QuestionPage({Key key, @required this.controller}) : super(key: key);

  @override
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  double _tweenEndValue = 1;
  PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = widget.controller;
  }

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

    return Padding(
      padding: const EdgeInsets.only(bottom: 100.0),
      child: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0.5, end: _tweenEndValue),
          curve: Curves.easeIn,
          duration: Duration(milliseconds: 650),
          onEnd: () {
            setState(() {
              _tweenEndValue = _tweenEndValue == 1 ? 0.2 : 1;
            });
          },
          builder: (_, double opacity, __) {
            return Align(
              alignment: Alignment.bottomCenter,
              child: Opacity(
                opacity: opacity,
                child: GestureDetector(
                    onTap: () {
                      if (pageController.hasClients) {
                        pageController.animateToPage(
                          1,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: textButton),
              ),
            );
          }),
    );
  }
}
