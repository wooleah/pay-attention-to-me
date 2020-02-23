import 'package:flutter/material.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'constants.dart' as Constants;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();

  @override
  void initState() {
    super.initState();
    assetsAudioPlayer = AssetsAudioPlayer();
    assetsAudioPlayer.openPlaylist(
      Playlist(
        assetAudioPaths:
            Constants.voiceDataList.map((file) => file['path']).toList(),
      ),
    );
    assetsAudioPlayer.stop();

    assetsAudioPlayer.finished.listen((finished) {
      assetsAudioPlayer.stop();
    });
  }

  @override
  void dispose() {
    assetsAudioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('I need attention'),
        ),
        body: SafeArea(
          child: Center(
            child: Scrollbar(
              child: ListView(
                children: <Widget>[
                  for (var i = 0; i < Constants.voiceDataList.length; i++)
                    voiceBtn(i, Constants.voiceDataList[i]['title'])
                ],
              ),
            ),
          ),
        ),
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
