import 'package:flutter/material.dart';

import 'package:weather_app/home.dart';

main(List<String> args) => MyApp();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.lightGreen),
      home: Home(),
    );
  }
}
