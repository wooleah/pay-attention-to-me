library constants;

import 'package:flutter/material.dart';

import 'models/audiofile.dart';

const Color color1 = Color(0xff025159);
const Color color2 = Color(0xff03A696);
const Color color3 = Color(0xffF28705);
const Color color4 = Color(0xffF25D27);
const Color color5 = Color(0xffF20505);

const Color color6 = Color(0xffF2CAA7);

const List<Color> colorWheel = [color1, color2, color3, color4, color5];

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
