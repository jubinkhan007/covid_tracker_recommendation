import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'stats_screen.dart';

void main() => runApp(CoronavirusTracker());

class CoronavirusTracker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: kColourPrimary,
        scaffoldBackgroundColor: kColourBackground,
      ),
      home: StatsScreen(),
    );
  }
}