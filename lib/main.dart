import 'package:flutter/material.dart';
import 'wrapper.dart';

void main() => runApp(RootApp());

class RootApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Wrapper(),
      theme: ThemeData(
        fontFamily: 'Quicksand',
      ),
    );
  }
}
