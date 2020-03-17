import 'dart:convert';
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
      var fileList = Directory('${docDir.path}/audio').listSync();

      var encodedFileOrderList = await getEncodedFileOrderList();

      // Re-make the audioFileList when sharedPref's encodedFileOrderList is empty or it doesn't match with actual fileList
      if (encodedFileOrderList == null ||
          encodedFileOrderList.length != fileList.length) {
        _audioFileList = fileList.map((file) {
          int colorIndex = count % _theme.themeSet.length;
          count++;
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

        // save the list in sharedPref
        await saveEncodedFileOrderList(_audioFileList);
      } else {
        var fileUriMap = {};
        fileList.forEach((file) => fileUriMap[file.uri.toString()] = file);

        // Make an empty List and fill them in order
        var orderedFileList = List(fileList.length);
        for (var i = 0; i < encodedFileOrderList.length; ++i) {
          Map<String, dynamic> decoded = jsonDecode(encodedFileOrderList[i]);
          orderedFileList[i] = {
            'file': fileUriMap[decoded['uri']],
            'colorIndex': decoded['colorIndex'],
            'background': decoded['background'],
          };
        }

        _audioFileList = orderedFileList.map((fileObj) {
          _lastColorIndex = count % _theme.themeSet.length;
          count++;
          Map<String, dynamic> selectedThemeSet =
              _theme.themeSet[fileObj['colorIndex']];
          return new AudioFile(
            uri: fileObj['file'].uri.toString(),
            path: fileObj['file'].path,
            title: path.basenameWithoutExtension(fileObj['file'].path),
            color: selectedThemeSet['color'],
            background: selectedThemeSet['background'],
            colorIndex: fileObj['colorIndex'],
          );
        }).toList();
      }
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
          return Scaffold(
            body: Center(),
          );
        }
      },
    );
  }
}
