import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';

import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:heyListen/models/customTheme.dart';
import 'package:heyListen/util/commonFileFunc.dart';

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
  final Function onFilesImportedCb;
  final CustomTheme theme;

  const Recorder({this.onFileSaveCb, this.onFilesImportedCb, this.theme});

  @override
  _RecorderState createState() => _RecorderState();
}

class _RecorderState extends State<Recorder> {
  FlutterSound flutterSound;
  RecorderState _recorderStatus;
  int _totalRecordedTime;
  String _recorderTxt = '00:00:00';
  String _recordedFilePath;
  bool _isSaveButtonDisabled = true;

  StreamSubscription<RecordStatus> _recorderSubscription;
  StreamSubscription<PlayStatus> _playerSubscription;

  TextEditingController _fileNameTextFieldController;

  @override
  void initState() {
    super.initState();
    flutterSound = FlutterSound();
    _fileNameTextFieldController = TextEditingController();
  }

  @override
  void dispose() {
    if (_recorderStatus == RecorderState.RECORDING) {
      flutterSound.stopRecorder();
    }
    if (_recorderStatus == RecorderState.PLAYING) {
      flutterSound.stopPlayer();
    }
    _fileNameTextFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.theme.fabColor,
      height: 250,
      padding: const EdgeInsets.only(top: 5, right: 10),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Transform.rotate(
                angle: pi,
                child: IconButton(
                  icon: Icon(
                    Entypo.export,
                    size: 30,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    List<File> importedFiles = await FilePicker.getMultiFile();
                    if (importedFiles == null || importedFiles.length == 0) {
                      return;
                    }

                    List<Future<File>> copiedFileFutureList = [];
                    // File file = await FilePicker.getFile();

                    Directory docDir = await getApplicationDocumentsDirectory();
                    // Copy all of the files to the audio dir
                    importedFiles.forEach((file) {
                      String fileName =
                          path.basenameWithoutExtension(file.path);
                      copiedFileFutureList
                          .add(file.copy('${docDir.path}/audio/$fileName.aac'));
                    });
                    // And wait till all of them resolves
                    List<File> copiedFiles =
                        await Future.wait(copiedFileFutureList);
                    widget.onFilesImportedCb(copiedFiles);
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
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
                onPressed: _isSaveButtonDisabled
                    ? null
                    : () async {
                        String text = await _showFileNameDialog(context);
                        if (text == null) {
                          return;
                        }

                        File file = File(_recordedFilePath);
                        Directory docDir =
                            await getApplicationDocumentsDirectory();
                        File newFile = await moveFile(
                            file, '${docDir.path}/audio', '$text.aac');
                        widget.onFileSaveCb(newFile);
                        Navigator.of(context).pop();
                      },
                child: Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 20,
                    color:
                        _isSaveButtonDisabled ? Colors.white24 : Colors.white,
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
    await flutterSound.startRecorder(
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
      _isSaveButtonDisabled = false;
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

  Future<String> _showFileNameDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Name of your file?',
            style: TextStyle(),
          ),
          content: TextField(
            controller: _fileNameTextFieldController,
            decoration: InputDecoration(
                hintText: 'My file name', hintStyle: TextStyle()),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                'OK',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                if (_fileNameTextFieldController.text.isEmpty) return;
                Navigator.of(context).pop(_fileNameTextFieldController.text);
              },
            ),
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
