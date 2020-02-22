import 'package:flutter/material.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'constants.dart' as Constants;

void main() => runApp(RootApp());

class RootApp extends StatefulWidget {
  @override
  _RootAppState createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();

  @override
  void initState() {
    super.initState();
    assetsAudioPlayer = AssetsAudioPlayer();
    assetsAudioPlayer.openPlaylist(
      Playlist(
        assetAudioPaths: [
          "assets/sounds/payattentiontome.mp3",
          "assets/sounds/payattentionsong.mp3",
          "assets/sounds/honkyboysong.mp3",
          "assets/sounds/moo.mp3",
          "assets/sounds/Woojae!.mp3",
          "assets/sounds/yousook.mp3",
          "assets/sounds/suckmybutt.mp3",
          "assets/sounds/whatsfordinner.mp3",
          "assets/sounds/whatta.mp3",
          "assets/sounds/questionbutnot.mp3",
          "assets/sounds/cerealparty.mp3",
          "assets/sounds/ipooped.mp3",
          "assets/sounds/leavemealone.mp3",
        ]
      )
    );
    assetsAudioPlayer.stop();

    assetsAudioPlayer.finished.listen((finished){
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
        body: SafeArea(child: Center(
          child: Scrollbar(
            child: ListView(
              children: <Widget>[
                voiceBtn(0, 'Pay attention to me!', Constants.color1),
                voiceBtn(1, 'Pay attention song', Constants.color2),
                voiceBtn(2, 'HB song', Constants.color3),
                voiceBtn(3, 'Moo', Constants.color4),
                voiceBtn(4, 'Woojae!', Constants.color5),
                voiceBtn(5, 'You sook', Constants.color1),
                voiceBtn(6, 'Suck mabutt', Constants.color2),
                voiceBtn(7, "What's for dinner", Constants.color3),
                voiceBtn(8, 'What-ta', Constants.color4),
                voiceBtn(9, 'Question but not', Constants.color5),
                voiceBtn(10, 'Cereal party!', Constants.color1),
                voiceBtn(11, 'I puped', Constants.color2),
                voiceBtn(12, 'Leave me alone', Constants.color3),
              ],
            ),
          ),
        ),),
      ), 
    );
  }

  Widget voiceBtn(int fileIndex, String text, Color color) {
    return SizedBox(
      height: 100,
      child: RaisedButton(
        onPressed: () {
          assetsAudioPlayer.playlistPlayAtIndex(fileIndex);
        },
        child: Text(text, 
          style: TextStyle(
            fontSize: 24,
            color: Colors.white
          ),
        ),
        color: color,
      ),
    );
  }
}