import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart' show rootBundle;
import 'package:heyListen/models/audiofile.dart';
import 'package:heyListen/models/customTheme.dart';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:heyListen/util/commonFileFunc.dart';
import '../constants.dart' as Constants;

// Prepare initial voice
Future<void> addTutorialVoice() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool gotTutorialFile = prefs.getBool('gotTutorialFile');
  if (gotTutorialFile == true) {
    return;
  }

  try {
    var initialVoice1 = await rootBundle.load('assets/sounds/initial_voice1.mp3');
    var initialVoice2 = await rootBundle.load('assets/sounds/initial_voice2.mp3');
    var initialVoice3 = await rootBundle.load('assets/sounds/initial_voice3.mp3');
    var initialVoice4 = await rootBundle.load('assets/sounds/initial_voice4.mp3');
    var initialVoice5 = await rootBundle.load('assets/sounds/initial_voice5.mp3');

    String appDir = (await getApplicationDocumentsDirectory()).path;
    // Create audio directory
    Directory('$appDir/audio').createSync();
    String audioFileDirPath = Directory('$appDir/audio').path;
    // Copy initial voices into the audio directory
    var file1 = await writeToFile(initialVoice1, '$audioFileDirPath/Hi!.mp3');
    var file2 = await writeToFile(initialVoice2, '$audioFileDirPath/Change the colors.mp3');
    var file3 = await writeToFile(initialVoice3, '$audioFileDirPath/Move me around.mp3');
    var file4 = await writeToFile(initialVoice4, '$audioFileDirPath/Record your voice.mp3');
    var file5 = await writeToFile(initialVoice5, '$audioFileDirPath/Thank you!.mp3');
    await prefs.setBool('gotTutorialFile', true);

    // Make the audioFileList to set the initial order of these voices
    List<FileSystemEntity> fileList = [file1, file2, file3, file4, file5];
    List<AudioFile> audioFileList = [];
    int count = 0;
    var theme = Constants.ThemeList[Constants.defaultThemeName];

    audioFileList = fileList.map((file) {
      int colorIndex = count % theme.themeSet.length;
      count++;

      Map<String, dynamic> selectedThemeSet = theme.themeSet[colorIndex];
      return new AudioFile(
        uri: file.uri.toString(),
        path: file.path,
        title: path.basenameWithoutExtension(file.path),
        color: selectedThemeSet['color'],
        background: selectedThemeSet['background'],
        colorIndex: colorIndex,
      );
    }).toList();

    // save the list in sharedPref
    await saveEncodedFileOrderList(audioFileList);
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
  return {'themeName': prefs.getString('themeName'), 'fontSize': prefs.getDouble('fontSize')};
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
