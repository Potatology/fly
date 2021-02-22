import 'package:blackfly/pages/altitude_page.dart';
import 'package:blackfly/widgets/logo.dart';
import 'package:blackfly/pages/map_range_page.dart';
import 'package:blackfly/pages/question_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLACKFLY',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Logo(),
            SizedBox(
              height: 400,
              width: 400,
              child: PageView(
                children: [QuestionPage(), MapRangePage(), AltitudePage()],
              ),
            )
          ],
        ),
      ),
    );
  }
}