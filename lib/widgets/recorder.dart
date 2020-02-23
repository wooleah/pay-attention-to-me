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
  @override
  _RecorderState createState() => _RecorderState();
}

class _RecorderState extends State<Recorder> {
  FlutterSound flutterSound;
  RecorderState _recorderStatus;
  int _totalRecordedTime;
  String _recorderTxt = '00:00:00';
  String _recordedFilePath;

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
      height: 50,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          getRecorderButton(_recorderStatus),
          Text(
            '$_recorderTxt',
            style: TextStyle(color: Colors.white),
          )
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

    print('startRecorder: $path');
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
    print('stopRecorder: $path');
    setState(() {
      _recorderStatus = RecorderState.RECORD_DONE;
    });
    _recordedFilePath = path;

    // Change timer text from recorder time to playable time
    setState(() {
      _recorderTxt = getTimeInFormat(_totalRecordedTime).substring(0, 8);
    });

    // Reset subscription
    if (_recorderSubscription != null) {
      _recorderSubscription.cancel();
      _recorderSubscription = null;
    }
  }

  Future<void> startPlayer() async {
    String path = await flutterSound.startPlayer(_recordedFilePath);

    print('startPlayer: $path');
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
    String result = await flutterSound.pausePlayer();
    setState(() {
      _recorderStatus = RecorderState.PAUSED;
    });
  }

  Future<void> resumePlayer() async {
    String result = await flutterSound.resumePlayer();
    setState(() {
      _recorderStatus = RecorderState.PLAYING;
    });
  }

  Future<void> stopPlayer({playerStopped = false}) async {
    if (!playerStopped) {
      String path = await flutterSound.stopPlayer();
      print('stopPlayer: $path');
    }

    setState(() {
      _recorderStatus = RecorderState.PLAY_DONE;
    });

    if (_playerSubscription != null) {
      _playerSubscription.cancel();
      _playerSubscription = null;
    }
  }
}
