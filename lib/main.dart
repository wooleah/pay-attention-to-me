import 'wrapper.dart';

import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flare_splash_screen/flare_splash_screen.dart';

import 'package:heyListen/models/customTheme.dart';
import 'package:heyListen/util/settingsManager.dart';
import 'home_screen.dart';
import 'models/audiofile.dart';
import 'constants.dart' as Constants;

void main() => runApp(RootApp());

class RootApp extends StatelessWidget {
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
      if (encodedFileOrderList == null || encodedFileOrderList.length != fileList.length) {
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

        _audioFileList = orderedFileList.where((fileObj) => fileObj['file'] != null).map((fileObj) {
          _lastColorIndex = count % _theme.themeSet.length;
          count++;
          Map<String, dynamic> selectedThemeSet = _theme.themeSet[fileObj['colorIndex']];

          return new AudioFile(
            uri: fileObj['file'].uri.toString(),
            path: fileObj['file'].path,
            title: path.basenameWithoutExtension(fileObj['file'].path),
            color: selectedThemeSet['color'],
            background: fileObj['background'],
            colorIndex: fileObj['colorIndex'],
          );
        }).toList();
      }
    } on FileSystemException {
      new Directory('${docDir.path}/audio').createSync();
    }
  }

  Future<void> _init() async {
    await _preparePrevSettings();
    await addTutorialVoice();
    await _getListOfFiles();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        //add builder here to have a context where navigator is available
        builder: (context) => SplashScreen.callback(
          name: 'assets/animations/Listen.flr',
          width: double.infinity,
          fit: BoxFit.cover,
          onSuccess: (_) {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, __, ___) {
                  return HomeScreen(
                    initialTheme: _theme,
                    initialItemFontSize: _itemFontSize,
                    initialAudioFileList: _audioFileList,
                    initialLastColorIndex: _lastColorIndex,
                  );
                },
                transitionDuration: Duration(milliseconds: 500),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  var begin = Offset(0.0, 1.0);
                  var end = Offset.zero;
                  var curve = Curves.easeIn;

                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
              ),
            );
          },
          loopAnimation: 'Go',
          until: () => Future.wait([_init()]),
          endAnimation: 'Go',
          onError: (error, stacktrace) {
            print(error);
          },
        ),
      ),
      theme: ThemeData(
        fontFamily: 'Quicksand',
      ),
    );

    // FutureBuilder(
    //   future: Future.wait([
    //     _init(),
    //   ]),
    //   builder: (context, snapshot) {
    //     if (snapshot.connectionState == ConnectionState.done) {
    //       return HomeScreen(
    //         initialTheme: _theme,
    //         initialItemFontSize: _itemFontSize,
    //         initialAudioFileList: _audioFileList,
    //         initialLastColorIndex: _lastColorIndex,
    //       );
    //     } else {
    //       return Scaffold(
    //         body: Center(),
    //       );
    //     }
    //   },
    // )
  }
}
