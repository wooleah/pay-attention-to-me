import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
// import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:pay_attention_to_me/widgets/recorder.dart';
import 'constants.dart' as Constants;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FlutterSound flutterSound;
  // AssetsAudioPlayer assetsAudioPlayer;
  List<FileSystemEntity> _fileList = new List();

  @override
  void initState() {
    super.initState();
    flutterSound = FlutterSound();

    _getListOfFiles();
    // Create player instance
    // assetsAudioPlayer = AssetsAudioPlayer();
    // assetsAudioPlayer.openPlaylist(
    //   Playlist(
    //     assetAudioPaths:
    //         Constants.voiceDataList.map((file) => file.path).toList(),
    //   ),
    // );
    // assetsAudioPlayer.stop();

    // assetsAudioPlayer.finished.listen((finished) {
    //   assetsAudioPlayer.stop();
    // });
  }

  @override
  void dispose() {
    // assetsAudioPlayer.stop();
    // assetsAudioPlayer.dispose();
    // if (_recorderStatus == RecorderState.PLAYING) {
    //   flutterSound.stopPlayer();
    // }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('I need attention'),
      ),
      body: SafeArea(
        child: Center(
          child: Scrollbar(
            child: ListView.builder(
              itemCount: _fileList.length,
              itemBuilder: (context, index) {
                // return voiceBtn(index, Constants.voiceDataList[index].title);
                return voiceBtn(index, _fileList[index].uri.toString());
              },
              // children: <Widget>[
              //   for (var i = 0; i < Constants.voiceDataList.length; i++)
              //     voiceBtn(i, Constants.voiceDataList[i].title)
              // ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.yellowAccent,
        foregroundColor: Colors.blueAccent,
        onPressed: () {
          // TODO show recorder
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Recorder(
                onFileSaveCb: _getListOfFiles,
              );
            },
          );
        },
      ),
    );
  }

  Widget voiceBtn(int index, String uri, [Color color]) {
    final Color itemColor =
        color ?? Constants.colorWheel[index % Constants.colorWheel.length];
    return SizedBox(
      height: 100,
      child: RaisedButton(
        onPressed: () {
          // assetsAudioPlayer.playlistPlayAtIndex(index);
          startPlayer(uri);
        },
        child: Text(
          Uri.decodeFull(path.basenameWithoutExtension(uri)),
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
        color: itemColor,
      ),
    );
  }

  Future<void> _getListOfFiles() async {
    Directory docDir = await getApplicationDocumentsDirectory();
    setState(() {
      try {
        _fileList = Directory('${docDir.path}/audio').listSync();
      } on FileSystemException catch (err) {
        new Directory('${docDir.path}/audio').createSync();
      }
    });
  }

  Future<void> startPlayer(uri) async {
    try {
      await flutterSound.stopPlayer();
    } catch (err) {} finally {
      await flutterSound.startPlayer(uri);
    }
  }
}
