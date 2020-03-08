import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:heyListen/models/customTheme.dart';
import 'package:heyListen/util/settingsManager.dart';
import 'home_screen.dart';
import 'models/audiofile.dart';
import 'constants.dart' as Constants;

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  CustomTheme _theme;
  double _itemFontSize;
  List<AudioFile> _audioFileList = [];
  int _lastColorIndex = 0;

  Future<void> _preparePrevSettings() async {
    var prevSettings = await getSettings();
    var themeName = prevSettings['themeName'] ?? Constants.defaultThemeName;
    _theme = Constants.ThemeList[themeName];
    _itemFontSize = prevSettings['fontSize'] ?? Constants.defaultFontSize;
  }

  Future<void> _getListOfFiles() async {
    Directory docDir = await getApplicationDocumentsDirectory();
    int count = 0;
    try {
      _audioFileList = Directory('${docDir.path}/audio').listSync().map((file) {
        int colorIndex = count++ % _theme.themeSet.length;
        _lastColorIndex = colorIndex;
        Map<String, dynamic> selectedThemeSet = _theme.themeSet[colorIndex];
        return new AudioFile(
          uri: file.uri.toString(),
          path: file.path,
          title: path.basenameWithoutExtension(file.path),
          color: selectedThemeSet['color'],
          background: selectedThemeSet['background'],
          colorIndex: colorIndex,
        );
      }).toList();
      // _audioFileList = Directory('${docDir.path}/audio').listSync();
    } on FileSystemException {
      new Directory('${docDir.path}/audio').createSync();
    }
  }

  Future<void> _init() async {
    await addTutorialVoice();
    await _preparePrevSettings();
    await _getListOfFiles();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        _init(),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return HomeScreen(
            initialTheme: _theme,
            initialItemFontSize: _itemFontSize,
            initialAudioFileList: _audioFileList,
            initialLastColorIndex: _lastColorIndex,
          );
        } else {
          return Scaffold(body: CircularProgressIndicator());
        }
      },
    );
  }
}
