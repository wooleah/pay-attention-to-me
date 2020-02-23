import 'package:flutter/material.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:pay_attention_to_me/widgets/recorder.dart';
import 'constants.dart' as Constants;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AssetsAudioPlayer assetsAudioPlayer;
  FlutterSound flutterSound;

  @override
  void initState() {
    super.initState();
    // Create player instance
    flutterSound = FlutterSound();
    assetsAudioPlayer = AssetsAudioPlayer();
    assetsAudioPlayer.openPlaylist(
      Playlist(
        assetAudioPaths:
            Constants.voiceDataList.map((file) => file.path).toList(),
      ),
    );
    assetsAudioPlayer.stop();

    assetsAudioPlayer.finished.listen((finished) {
      assetsAudioPlayer.stop();
    });
  }

  @override
  void dispose() {
    assetsAudioPlayer.stop();
    assetsAudioPlayer.dispose();
    flutterSound.stopRecorder();
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
            child: ListView(
              children: <Widget>[
                for (var i = 0; i < Constants.voiceDataList.length; i++)
                  voiceBtn(i, Constants.voiceDataList[i].title)
              ],
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
              return Container(
                height: 250,
                child: Recorder(),
              );
            },
          );
        },
      ),
    );
  }

  Widget voiceBtn(int index, String text, [Color color]) {
    final Color itemColor =
        color ?? Constants.colorWheel[index % Constants.colorWheel.length];
    return SizedBox(
      height: 100,
      child: RaisedButton(
        onPressed: () {
          assetsAudioPlayer.playlistPlayAtIndex(index);
        },
        child: Text(
          text,
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
        color: itemColor,
      ),
    );
  }
}
