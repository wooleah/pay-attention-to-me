import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart';

import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';

enum RecorderState {
  RECORD_READY,
  RECORDING,
  RECORD_DONE,
  PLAYING,
  PAUSED,
  PLAY_DONE
}

class Recorder extends StatefulWidget {
  final Function onFileSaveCb;

  const Recorder({this.onFileSaveCb});

  @override
  _RecorderState createState() => _RecorderState();
}

class _RecorderState extends State<Recorder> {
  FlutterSound flutterSound;
  RecorderState _recorderStatus;
  int _totalRecordedTime;
  String _recorderTxt = '00:00:00';
  String _recordedFilePath;
  bool _isButtonDisabled = true;

  StreamSubscription<RecordStatus> _recorderSubscription;
  StreamSubscription<PlayStatus> _playerSubscription;

  @override
  void initState() {
    super.initState();
    flutterSound = FlutterSound();
  }

  @override
  void dispose() {
    if (_recorderStatus == RecorderState.RECORDING) {
      flutterSound.stopRecorder();
    }
    if (_recorderStatus == RecorderState.PLAYING) {
      flutterSound.stopPlayer();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      height: 250,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                getRecorderButton(_recorderStatus),
                Text(
                  '$_recorderTxt',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              FlatButton(
                disabledColor: Colors.transparent,
                onPressed: _isButtonDisabled
                    ? null
                    : () async {
                        String text = await _showFileNameDialog(context);
                        File file = File(_recordedFilePath);
                        Directory docDir =
                            await getApplicationDocumentsDirectory();
                        moveFile(file, '${docDir.path}/audio', '$text.aac');
                        widget.onFileSaveCb();
                        Navigator.of(context).pop();
                      },
                child: Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 20,
                    color: _isButtonDisabled ? Colors.white24 : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget getRecorderButton(status) {
    IconData icon;
    Function cb;
    switch (status) {
      case RecorderState.RECORDING:
        icon = Icons.stop;
        cb = stopRecorder;
        break;
      case RecorderState.RECORD_DONE:
        icon = Icons.play_arrow;
        cb = startPlayer;
        break;
      case RecorderState.PLAYING:
        icon = Icons.pause;
        cb = pausePlayer;
        break;
      case RecorderState.PAUSED:
        icon = Icons.play_arrow;
        cb = resumePlayer;
        break;
      case RecorderState.PLAY_DONE:
        icon = Icons.replay;
        cb = startPlayer;
        break;
      case RecorderState.RECORD_READY:
      default:
        icon = Icons.fiber_manual_record;
        cb = startRecorder;
        break;
    }

    return IconButton(
      icon: Icon(icon),
      color: Colors.white,
      iconSize: 40,
      onPressed: cb,
    );
  }

  String getTimeInFormat(timePassed) {
    DateTime date = new DateTime.fromMillisecondsSinceEpoch(timePassed);
    return DateFormat('mm:ss:SS', 'en_US').format(date);
  }

  Future<void> startRecorder() async {
    Directory tempDir = await getTemporaryDirectory();
    File outputFile = File('${tempDir.path}/flutter_sound-tmp.aac');
    String path = await flutterSound.startRecorder(
      uri: outputFile.path,
      codec: t_CODEC.CODEC_AAC,
    );

    setState(() {
      _recorderStatus = RecorderState.RECORDING;
    });

    _recorderSubscription = flutterSound.onRecorderStateChanged.listen((e) {
      if (e == null) return;
      _totalRecordedTime = e.currentPosition.toInt();

      setState(() {
        _recorderTxt = getTimeInFormat(_totalRecordedTime).substring(0, 8);
      });
    });
  }

  Future<void> stopRecorder() async {
    String path = await flutterSound.stopRecorder();

    // Change recorderState
    setState(() {
      _recorderStatus = RecorderState.RECORD_DONE;
    });
    _recordedFilePath = path;

    // Change timer text from recorder time to playable time
    setState(() {
      _isButtonDisabled = false;
      _recorderTxt = getTimeInFormat(_totalRecordedTime).substring(0, 8);
    });

    // Reset subscription
    if (_recorderSubscription != null) {
      _recorderSubscription.cancel();
      _recorderSubscription = null;
    }
  }

  Future<void> startPlayer() async {
    await flutterSound.startPlayer(_recordedFilePath);

    setState(() {
      _recorderStatus = RecorderState.PLAYING;
    });

    _playerSubscription = flutterSound.onPlayerStateChanged.listen((e) {
      if (e == null) return;
      if (e.duration <= e.currentPosition) {
        stopPlayer(playerStopped: true);
      }

      // setState(() {
      //   _recorderTxt = getTimeInFormat(e.currentPosition.toInt()).substring(0, 8);
      // });
    });
  }

  Future<void> pausePlayer() async {
    await flutterSound.pausePlayer();
    setState(() {
      _recorderStatus = RecorderState.PAUSED;
    });
  }

  Future<void> resumePlayer() async {
    await flutterSound.resumePlayer();
    setState(() {
      _recorderStatus = RecorderState.PLAYING;
    });
  }

  Future<void> stopPlayer({playerStopped = false}) async {
    if (!playerStopped) {
      await flutterSound.stopPlayer();
    }

    setState(() {
      _recorderStatus = RecorderState.PLAY_DONE;
    });

    if (_playerSubscription != null) {
      _playerSubscription.cancel();
      _playerSubscription = null;
    }
  }

  Future<File> moveFile(
      File sourceFile, String newPath, String fileName) async {
    try {
      // rename is faster than copy
      return await sourceFile.rename('$newPath/$fileName');
    } on FileSystemException catch (err) {
      // if rename fails, copy the source file and delete it after copying
      final newFile = await sourceFile.copy('$newPath/$fileName');
      await sourceFile.delete();
      return newFile;
    }
  }

  Future<String> _showFileNameDialog(BuildContext context) async {
    TextEditingController _textFieldController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Name of your file?'),
          content: TextField(
              controller: _textFieldController,
              decoration: InputDecoration(hintText: 'My file name')),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(_textFieldController.text);
              },
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
    // File file = File(_recordedFilePath);
    // Directory docDir =
    //     await getApplicationDocumentsDirectory();
    // moveFile(
    //     file, '${docDir.path}/audio', 'recorder-test.aac');
  }
}
