import 'dart:async';
import 'package:dashboard/UI/general/generalWidgets.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:dashboard/UI/inside/timeline.dart';

import 'mobileStep.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  String userType;
  double opacity = 0;
  Future getJwt() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      opacity = 1;
      userType = prefs.get("userType");
    });
  }

  @override
  void initState() {
    getJwt().then((sda) {
      Timer(Duration(seconds: 2), () {
        buildNavigationMethod(
            context, userType == null ? MobileStep() : Timeline(), true);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    ThemeData theme = Theme.of(context);
    return Scaffold(
      body: Container(
        height: height,
        color: theme.primaryColor,
        width: width,
        child: AnimatedOpacity(
          duration: Duration(seconds: 2),
          opacity: opacity,
          curve: Curves.easeInOut,
          child: Center(
            child: Image.asset(
              "assets/images/logo.png",
              height: width,
              width: width,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
