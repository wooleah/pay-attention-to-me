library constants;

import 'package:flutter/material.dart';
import 'models/audiofile.dart';

const Color correctColor = Color(0xff78BF45);
const Color wrongColor = Color(0xffF26666);
const Color editColor = Colors.black;

const Map<dynamic, Map> ThemeList = {
  'Cat': ColorTheme_cat,
  'Dog': ColorTheme_dog,
  'Message': ColorTheme_message,
  'Space': ColorTheme_space,
  'Sunset': ColorTheme_sunset,
};

const String defaultThemeName = 'Cat';
const Map<String, dynamic> ColorTheme_dog = {
  'themeName': 'Dog',
  'colors': [
    Color(0xffD97941), 
    Color(0xff6A9988),
    Color(0xffEDC6B2), 
    Color(0xffBF7C63), 
    Color(0xffA05D22), 
  ],
  'appTitleColor': Color(0xff4F2C18),
  'appTitleBackgroundColor': Colors.white,
  'FABColor': Color(0xffD97941),
  'appBarImagePath': 'assets/images/dog.png'
};

const Map<String, dynamic> ColorTheme_cat = {
  'themeName': 'Cat',
  'colors': [
    Color(0xff9CC1D9), 
    Color(0xffA7CFF2), 
    Color(0xff8DA6A1), 
    Color(0xff61808C), 
    Color(0xff403B38),
  ],
  'appTitleColor': Color(0xff195275),
  'appTitleBackgroundColor': Colors.white,
  'FABColor': Color(0xffEB7E44),
  'appBarImagePath': 'assets/images/cat.png'
};

const Map<String, dynamic> ColorTheme_message = {
  'themeName': 'Message',
  'colors': [
    Color(0xff01151A), 
    Color(0xff92DEFF), 
    Color(0xff25D995), 
    Color(0xffFFE000), 
    Color(0xffF00801)
  ],
  'appTitleColor': Color(0xff01151A),
  'appTitleBackgroundColor': Colors.white,
  'FABColor': Color(0xff01151A),
  'appBarImagePath': 'assets/images/message.png'
};

const Map<String, dynamic> ColorTheme_space = {
  'themeName': 'Space',
  'colors': [
    Color(0xff51608C), 
    Color(0xff7E94D9), 
    Color(0xff8C919F), 
    Color(0xffBFC5D9), 
    Color(0xff343D59)
  ],
  'appTitleColor': Color(0xffE0E8FF),
  'appTitleBackgroundColor': Color(0xff56597A),
  'FABColor': Color(0xffF7D06F),
  'appBarImagePath': 'assets/images/space.png'
};

const Map<String, dynamic> ColorTheme_sunset = {
  'themeName': 'Sunset',
  'colors': [
    Color(0xff49669C), 
    Color(0xffF2C12E), 
    Color(0xffF26716), 
    Color(0xffD61C04), 
    Color(0xff332418)
  ],
  'appTitleColor': Color(0xffFFFED9),
  'appTitleBackgroundColor': Color(0xff332418),
  'FABColor': Color(0xff49669C),
  'appBarImagePath': 'assets/images/sunset.png'
};

const double defaultFontSize = 24;
const Map<String, double> FontSizes = {
  'Extra small': 16,
  'Small': 20,
  'Medium': 24,
  'Large': 28,
  'Extra large': 32,
};

const assetPath = 'assets/sounds';
List<AudioFile> voiceDataList = [
  AudioFile(
      path: "$assetPath/payattentiontome.mp3", title: 'Pay attention to me!'),
  AudioFile(
      path: "$assetPath/payattentionsong.mp3", title: 'Pay attention song'),
  AudioFile(path: "$assetPath/honkyboysong.mp3", title: 'HB song'),
  AudioFile(path: "$assetPath/moo.mp3", title: 'Moo'),
  AudioFile(path: "$assetPath/Woojae!.mp3", title: 'Woojae!'),
  AudioFile(path: "$assetPath/yousook.mp3", title: 'You sook'),
  AudioFile(path: "$assetPath/suckmybutt.mp3", title: 'Suck mabutt'),
  AudioFile(path: "$assetPath/whatsfordinner.mp3", title: "What's for dinner"),
  AudioFile(path: "$assetPath/whatta.mp3", title: 'What-ta'),
  AudioFile(path: "$assetPath/questionbutnot.mp3", title: 'Question but not'),
  AudioFile(path: "$assetPath/cerealparty.mp3", title: 'Cereal party!'),
  AudioFile(path: "$assetPath/ipooped.mp3", title: 'I puped'),
  AudioFile(path: "$assetPath/leavemealone.mp3", title: 'Leave me alone'),
];
