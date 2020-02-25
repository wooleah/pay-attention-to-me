import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:pay_attention_to_me/util/commonFileFunc.dart';
import 'package:pay_attention_to_me/widgets/recorder.dart';
import 'constants.dart' as Constants;
import 'models/audiofile.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FlutterSound flutterSound;
  // AssetsAudioPlayer assetsAudioPlayer;
  // List<FileSystemEntity> _audioFileList = new List();
  List<AudioFile> _audioFileList = new List();

  @override
  void initState() {
    super.initState();
    flutterSound = FlutterSound();

    _getListOfFiles();
  }

  @override
  void dispose() {
    // if (_recorderStatus == RecorderState.PLAYING) {
    //   flutterSound.stopPlayer();
    // }
    super.dispose();
  }

  Widget _getVoiceItem(BuildContext context, int index) {
    AudioFile audioFile = _audioFileList[index];
    final Color itemColor =
        Constants.colorWheel[index % Constants.colorWheel.length];
    File file = File(audioFile.path);

    return Slidable(
      key: Key(audioFile.uri),
      actionPane: SlidableScrollActionPane(),
      actionExtentRatio: 0.25,
      child: InkWell(
        onTap: () => startPlayer(audioFile.path),
        child: Container(
          height: 100,
          alignment: Alignment.center,
          child: Text(
            audioFile.title,
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
            ),
          ),
          color: itemColor,
        ),
      ),
      secondaryActions: <Widget>[
        IconSlideAction(
          color: Constants.correctColor,
          iconWidget: Icon(
            Icons.edit,
            color: Colors.white,
          ),
          onTap: () async {
            String newFileName =
                await _showFileNameDialog(context, audioFile.title);
            if (newFileName == null) {
              return;
            }

            Directory docDir = await getApplicationDocumentsDirectory();
            File newFile = await moveFile(
                file, '${docDir.path}/audio', '$newFileName.aac');

            setState(() {
              _audioFileList[index]
                  .update(newTitle: newFileName, newPath: newFile.path);
            });
          },
        ),
        IconSlideAction(
          color: Constants.wrongColor,
          icon: Icons.delete_forever,
          onTap: () {
            file.delete();
            setState(() {
              _audioFileList.removeAt(index);
            });
          },
        ),
      ],
    );
  }

  Future<String> _showFileNameDialog(
      BuildContext context, String currentName) async {
    TextEditingController _fileNameTextFieldController =
        TextEditingController();
    _fileNameTextFieldController.text = currentName;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Name of your file?'),
          content: TextField(controller: _fileNameTextFieldController),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(_fileNameTextFieldController.text);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _getListOfFiles() async {
    Directory docDir = await getApplicationDocumentsDirectory();
    setState(() {
      try {
        _audioFileList = Directory('${docDir.path}/audio')
            .listSync()
            .map((file) => new AudioFile(
                uri: file.uri.toString(),
                path: file.path,
                title: path.basenameWithoutExtension(file.path)))
            .toList();
        // _audioFileList = Directory('${docDir.path}/audio').listSync();
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
              itemCount: _audioFileList.length,
              itemBuilder: _getVoiceItem,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.yellowAccent,
        foregroundColor: Colors.blueAccent,
        onPressed: () {
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
}
