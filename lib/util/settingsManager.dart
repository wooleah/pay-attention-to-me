import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:heyListen/models/audiofile.dart';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:heyListen/util/commonFileFunc.dart';

// Prepare initial voice
Future<void> addTutorialVoice() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool gotTutorialFile = prefs.getBool('gotTutorialFile');
  if (gotTutorialFile == true) {
    return;
  }

  try {
    var initialVoice1 =
        await rootBundle.load('assets/sounds/initial_voice1.mp3');
    var initialVoice2 =
        await rootBundle.load('assets/sounds/initial_voice2.mp3');
    var initialVoice3 =
        await rootBundle.load('assets/sounds/initial_voice3.mp3');

    String appDir = (await getApplicationDocumentsDirectory()).path;
    // Create audio directory
    String audioFileDirPath = (await Directory('$appDir/audio').create()).path;
    await writeToFile(initialVoice1, '$audioFileDirPath/instruction1.mp3');
    await writeToFile(initialVoice2, '$audioFileDirPath/instruction2.mp3');
    await writeToFile(initialVoice3, '$audioFileDirPath/instruction3.mp3');
    await prefs.setBool('gotTutorialFile', true);
  } catch (err) {
    print(err.toString());
  }
}

// Save and get settings
Future<void> saveSettings({String themeName, double fontSize}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (themeName != null) {
    await prefs.setString('themeName', themeName);
  }
  if (fontSize != null) {
    await prefs.setDouble('fontSize', fontSize);
  }
}

Future<Map<String, dynamic>> getSettings() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return {
    'themeName': prefs.getString('themeName'),
    'fontSize': prefs.getDouble('fontSize')
  };
}

// Save and get fileOrderList(list of audioFile uris)
Future<void> saveEncodedFileOrderList(List<AudioFile> list) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> uriList;
  if (list.length == 0) {
    uriList = [];
  } else {
    uriList = list.map((AudioFile audioFile) {
      return jsonEncode({
        'uri': audioFile.uri,
        'colorIndex': audioFile.colorIndex,
        'background': audioFile.background,
      });
    }).toList();
  }

  await prefs.setStringList('encodedFileOrderList', uriList);
}

Future<List<String>> getEncodedFileOrderList() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    return prefs.getStringList('encodedFileOrderList');
  } catch (err) {
    return null;
  }
}
