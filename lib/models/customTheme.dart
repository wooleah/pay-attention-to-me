import 'package:flutter/material.dart';

class CustomTheme {
  final String themeName;
  final List<Color> colors;
  final List<Map<String, dynamic>>
      themeSet; // color and backgroundImgPath that matches that specific color
  final BoxFit boxfit; // optional
  final Color appTitleColor;
  final Color appTitleBackgroundColor;
  final Color listBackgroundColor;
  final Color fabColor;
  final String appBarImagePath;
  final Color settingsPageColor;

  const CustomTheme({
    this.themeName,
    this.colors,
    this.themeSet,
    this.boxfit,
    this.appTitleColor,
    this.appTitleBackgroundColor,
    this.listBackgroundColor,
    this.fabColor,
    this.appBarImagePath,
    this.settingsPageColor,
  });
}
