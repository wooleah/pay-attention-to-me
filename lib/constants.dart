library constants;

import 'package:flutter/material.dart';
import 'package:heyListen/models/customTheme.dart';

// const String appName = 'Hey, Listen - Customizable Soundboard';
const String ADMOB_ID = 'ca-app-pub-9868217644217042~5463981768';
const String PROD_ADUNIT_ID = 'ca-app-pub-9868217644217042/7483640443';
const String TEST_ADUNIT_ID = 'ca-app-pub-3940256099942544/1033173712';

const String companyLogoWithNamePath = 'assets/images/lovebirdsWithLogo.png';
const String companyLogoPath = 'assets/images/lovebirds.png';

const Color correctColor = Color(0xff78BF45);
const Color wrongColor = Color(0xffF26666);
const Color editColor = Colors.brown;
const Color shareColor = Colors.grey;

const Map<String, CustomTheme> ThemeList = {
  'Cat': ColorTheme_cat,
  'Dog': ColorTheme_dog,
  'Message': ColorTheme_message,
  'Space': ColorTheme_space,
  'Sunset': ColorTheme_sunset,
};

const String defaultThemeName = 'Cat';

const ColorTheme_dog = CustomTheme(
  themeName: 'Dog',
  colors: [
    Color(0xffD97941),
    Color(0xff6A9988),
    Color(0xffEDC6B2),
    Color(0xffBF7C63),
    Color(0xffA05D22),
  ],
  themeSet: [
    {'color': Color(0xffD97941), 'background': 'assets/images/bones.png'},
    {'color': Color(0xff6A9988), 'background': 'assets/images/xs.png'},
    {'color': Color(0xffEDC6B2), 'background': 'assets/images/paws.png'},
    {'color': Color(0xffBF7C63), 'background': 'assets/images/xs.png'},
    {'color': Color(0xffA05D22), 'background': 'assets/images/doghouse.png'},
  ],
  boxfit: BoxFit.fill,
  appTitleColor: Color(0xff4F2C18),
  appTitleBackgroundColor: Colors.white,
  fabColor: Color(0xffD97941),
  appBarImagePath: 'assets/images/dog.png',
  settingsPageColor: Colors.white,
);

const ColorTheme_cat = CustomTheme(
  themeName: 'Cat',
  colors: [
    Color(0xff9CC1D9),
    Color(0xffA7CFF2),
    Color(0xff8DA6A1),
    Color(0xff61808C),
    Color(0xff403B38),
  ],
  themeSet: [
    {'color': Color(0xff9CC1D9), 'background': 'assets/images/paws.png'},
    {'color': Color(0xffA7CFF2), 'background': 'assets/images/polkadots.png'},
    {'color': Color(0xff8DA6A1), 'background': 'assets/images/cattail.png'},
    {'color': Color(0xff61808C), 'background': 'assets/images/polkadots.png'},
    {'color': Color(0xff403B38), 'background': 'assets/images/tunacat.png'},
  ],
  boxfit: BoxFit.fill,
  appTitleColor: Color(0xff195275),
  appTitleBackgroundColor: Colors.white,
  fabColor: Color(0xffEB7E44),
  appBarImagePath: 'assets/images/cat.png',
  settingsPageColor: Colors.white,
);

const ColorTheme_message = CustomTheme(
  themeName: 'Message',
  colors: [
    Color(0xff01151A),
    Color(0xff92DEFF),
    Color(0xff25D995),
    Color(0xffFFE000),
    Color(0xffF00801),
  ],
  themeSet: [
    {'color': Color(0xff01151A), 'background': ''},
    {'color': Color(0xff92DEFF), 'background': ''},
    {'color': Color(0xff25D995), 'background': ''},
    {'color': Color(0xffFFE000), 'background': ''},
    {'color': Color(0xffF00801), 'background': ''},
  ],
  boxfit: BoxFit.fill,
  appTitleColor: Color(0xff01151A),
  appTitleBackgroundColor: Colors.white,
  fabColor: Color(0xff01151A),
  appBarImagePath: 'assets/images/message.png',
  settingsPageColor: Colors.white,
);

const ColorTheme_space = CustomTheme(
  themeName: 'Space',
  colors: [
    Color(0xff51608C),
    Color(0xff7E94D9),
    Color(0xff8C919F),
    Color(0xffBFC5D9),
    Color(0xff343D59),
  ],
  themeSet: [
    {'color': Color(0xff51608C), 'background': 'assets/images/ufos.png'},
    {'color': Color(0xff7E94D9), 'background': 'assets/images/stars.png'},
    {'color': Color(0xff8C919F), 'background': 'assets/images/earth.png'},
    {'color': Color(0xffBFC5D9), 'background': 'assets/images/stars.png'},
    {'color': Color(0xff343D59), 'background': 'assets/images/astronaut.png'},
  ],
  boxfit: BoxFit.fill,
  appTitleColor: Color(0xffE0E8FF),
  appTitleBackgroundColor: Color(0xff56597A),
  fabColor: Color(0xffF7D06F),
  appBarImagePath: 'assets/images/space.png',
  settingsPageColor: Color(0xff56597A),
);

const ColorTheme_sunset = CustomTheme(
  themeName: 'Sunset',
  colors: [
    Color(0xff49669C),
    Color(0xffF2C12E),
    Color(0xffF26716),
    Color(0xffD61C04),
    Color(0xff332418),
  ],
  themeSet: [
    {'color': Color(0xff49669C), 'background': 'assets/images/tent.png'},
    {'color': Color(0xffF2C12E), 'background': 'assets/images/clouds.png'},
    {'color': Color(0xffF26716), 'background': 'assets/images/cacti.png'},
    {'color': Color(0xffD61C04), 'background': 'assets/images/clouds.png'},
    {'color': Color(0xff332418), 'background': 'assets/images/mountains.png'},
  ],
  boxfit: BoxFit.fill,
  appTitleColor: Color(0xffFFFED9),
  appTitleBackgroundColor: Color(0xff332418),
  fabColor: Color(0xff49669C),
  appBarImagePath: 'assets/images/sunset.png',
  settingsPageColor: Color(0xff332418),
);

const double defaultFontSize = 24;
const Map<String, double> FontSizes = {
  'Extra small': 16,
  'Small': 20,
  'Medium': 24,
  'Large': 28,
  'Extra large': 32,
};

const settingsPageTextStyle = TextStyle(
  fontSize: 18,
);

// const assetPath = 'assets/sounds';
// List<AudioFile> voiceDataList = [
//   AudioFile(
//       path: "$assetPath/payattentiontome.mp3", title: 'Pay attention to me!'),
//   AudioFile(
//       path: "$assetPath/payattentionsong.mp3", title: 'Pay attention song'),
//   AudioFile(path: "$assetPath/honkyboysong.mp3", title: 'HB song'),
//   AudioFile(path: "$assetPath/moo.mp3", title: 'Moo'),
//   AudioFile(path: "$assetPath/Woojae!.mp3", title: 'Woojae!'),
//   AudioFile(path: "$assetPath/yousook.mp3", title: 'You sook'),
//   AudioFile(path: "$assetPath/suckmybutt.mp3", title: 'Suck mabutt'),
//   AudioFile(path: "$assetPath/whatsfordinner.mp3", title: "What's for dinner"),
//   AudioFile(path: "$assetPath/whatta.mp3", title: 'What-ta'),
//   AudioFile(path: "$assetPath/questionbutnot.mp3", title: 'Question but not'),
//   AudioFile(path: "$assetPath/cerealparty.mp3", title: 'Cereal party!'),
//   AudioFile(path: "$assetPath/ipooped.mp3", title: 'I puped'),
//   AudioFile(path: "$assetPath/leavemealone.mp3", title: 'Leave me alone'),
// ];
