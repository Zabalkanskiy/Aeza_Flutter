import 'package:flutter/material.dart';

class AppRoutes {
  static const String auth = '/auth';
  static const String gallery = '/gallery';
  static const String editor = '/editor';
}

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    default:
      return MaterialPageRoute(
        builder: (_) =>
            const Scaffold(body: Center(child: Text('Route not found'))),
      );
  }
}

