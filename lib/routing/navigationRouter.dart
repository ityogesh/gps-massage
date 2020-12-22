import 'package:flutter/material.dart';
import 'package:gps_massageapp/initialScreens/termsAndConditions.dart';
import 'package:gps_massageapp/serviceUser/register/registerUserScreen.dart';

class NavigationRouter {
  static void switchToRegistration(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => RegisterServiceUserScreen()),
        (Route<dynamic> route) => false);
  }

  static void switchToTermsandConditions(BuildContext context) {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => IntroTermsAndPolicy()));
  }
}
