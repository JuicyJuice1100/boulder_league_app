import 'package:flutter/material.dart';

class AppGlobal {
  AppGlobal._();

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static String title = 'Boulder League';
}